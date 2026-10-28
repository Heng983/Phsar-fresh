import { BadGatewayException, Injectable, Logger, ServiceUnavailableException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { createHmac, timingSafeEqual } from "crypto";

/** What PayWay answers for a KHQR purchase (payment_option = abapay_khqr_deeplink). */
export interface KhqrResult {
  qrString: string;
  deeplink: string | null;
  checkoutUrl: string | null;
}

export type PaywayStatus = "APPROVED" | "PENDING" | "FAILED";

export interface CheckResult {
  status: PaywayStatus;
  apv?: string;
  raw: Record<string, unknown>;
}

const b64 = (s: string) => Buffer.from(s, "utf8").toString("base64");

/** PayWay wants UTC `YYYYMMDDHHmmss`. */
export function reqTime(d = new Date()) {
  return d.toISOString().replace(/[-:T]/g, "").slice(0, 14);
}

/**
 * ABA PayWay (Checkout API). Docs: https://developer.payway.com.kh
 * Credentials come from the merchant profile ABA gives you (sandbox first):
 *   PAYWAY_MERCHANT_ID, PAYWAY_API_KEY, PAYWAY_BASE_URL.
 */
@Injectable()
export class PaywayClient {
  private readonly log = new Logger("PayWay");
  readonly merchantId: string;
  private readonly apiKey: string;
  private readonly callbackSecret: string;
  private readonly baseUrl: string;
  readonly callbackUrl: string | null;
  readonly appScheme: string;
  readonly lifetimeMinutes: number;
  /**
   * PAYWAY_MOCK=true: no PayWay at all. QRs are fake and a payment is "made"
   * with POST /orders/:id/payment/test-pay. Refused when NODE_ENV=production.
   */
  readonly mock: boolean;
  private readonly mockPaid = new Set<string>();

  constructor(config: ConfigService) {
    this.merchantId = config.get<string>("PAYWAY_MERCHANT_ID") ?? "";
    this.apiKey = config.get<string>("PAYWAY_API_KEY") ?? "";
    // The callback signature key; PayWay's sample calls it the "secret key".
    this.callbackSecret = config.get<string>("PAYWAY_CALLBACK_SECRET") || this.apiKey;
    // Just the host; a full endpoint URL pasted here still works.
    this.baseUrl = (config.get<string>("PAYWAY_BASE_URL") || "https://checkout-sandbox.payway.com.kh")
      .replace(/\/api\/.*$/, "")
      .replace(/\/+$/, "");
    this.callbackUrl = config.get<string>("PAYWAY_CALLBACK_URL") || null;
    this.appScheme = config.get<string>("PAYWAY_APP_RETURN_DEEPLINK") || "phsarfresh://payment";
    this.lifetimeMinutes = Math.max(3, Number(config.get("PAYWAY_QR_LIFETIME_MINUTES") ?? 15));
    this.mock = config.get<string>("PAYWAY_MOCK") === "true" && config.get<string>("NODE_ENV") !== "production";
    if (this.mock) this.log.warn("PAYWAY_MOCK=true: payments are simulated, no money moves");
  }

  get configured() {
    return this.mock || Boolean(this.merchantId && this.apiKey);
  }

  /** Test mode only: the customer "paid" this transaction. */
  mockPay(tranId: string) {
    this.mockPaid.add(tranId);
  }

  /** Base64 of HMAC-SHA512 over the values joined with no separator. */
  private hash(values: (string | number | null | undefined)[]) {
    const data = values.map((v) => (v === null || v === undefined ? "" : String(v))).join("");
    return createHmac("sha512", this.apiKey).update(data, "utf8").digest("base64");
  }

  private ensureConfigured() {
    if (!this.configured) {
      throw new ServiceUnavailableException({
        reason: "PAYMENT_NOT_CONFIGURED",
        message: "ABA PayWay isn't set up on the server yet (PAYWAY_MERCHANT_ID / PAYWAY_API_KEY)",
      });
    }
  }

  /** Creates a KHQR (payable with ABA Mobile or any KHQR bank app) plus an ABA Mobile deeplink. */
  async createKhqr(input: { tranId: string; amountCents: number; currency: "USD" | "KHR"; returnParams?: string }): Promise<KhqrResult> {
    this.ensureConfigured();
    if (this.mock) {
      // Not a real KHQR: banks will reject it. Scannable only to show the screen works.
      return { qrString: `PHSARFRESH-TEST|${input.tranId}|${(input.amountCents / 100).toFixed(2)} ${input.currency}`, deeplink: null, checkoutUrl: null };
    }
    const f = {
      req_time: reqTime(),
      merchant_id: this.merchantId,
      tran_id: input.tranId,
      amount: input.currency === "KHR" ? String(Math.round(input.amountCents)) : (input.amountCents / 100).toFixed(2),
      items: "",
      shipping: "",
      firstname: "",
      lastname: "",
      email: "",
      phone: "",
      type: "purchase",
      payment_option: "abapay_khqr_deeplink",
      return_url: this.callbackUrl ? b64(this.callbackUrl) : "",
      cancel_url: "",
      continue_success_url: "",
      return_deeplink: b64(JSON.stringify({ ios_scheme: this.appScheme, android_scheme: this.appScheme })),
      currency: input.currency,
      custom_fields: "",
      return_params: input.returnParams ?? "",
      payout: "",
      lifetime: String(this.lifetimeMinutes),
      additional_params: "",
      google_pay_token: "",
      skip_success_page: "",
    };
    // Order fixed by PayWay's Purchase API.
    const hash = this.hash([
      f.req_time, f.merchant_id, f.tran_id, f.amount, f.items, f.shipping, f.firstname, f.lastname, f.email, f.phone,
      f.type, f.payment_option, f.return_url, f.cancel_url, f.continue_success_url, f.return_deeplink, f.currency,
      f.custom_fields, f.return_params, f.payout, f.lifetime, f.additional_params, f.google_pay_token, f.skip_success_page,
    ]);

    const form = new FormData();
    for (const [k, v] of Object.entries(f)) if (v !== "") form.append(k, v);
    form.append("hash", hash);

    const body = await this.request("/api/payment-gateway/v1/payments/purchase", { method: "POST", body: form });
    const status = body.status as { code?: unknown; message?: unknown } | undefined;
    const qr = (body.qr_string ?? body.qrString) as string | undefined;
    if (!isOk(status?.code) || !qr) {
      this.log.warn(`purchase ${input.tranId} refused: ${JSON.stringify(status ?? body).slice(0, 300)}`);
      throw new BadGatewayException({
        reason: "PAYWAY_REFUSED",
        code: status?.code ?? null,
        message: `ABA PayWay couldn't create the QR${status?.message ? `: ${String(status.message)}` : ""}`,
      });
    }
    return {
      qrString: qr,
      deeplink: (body.abapay_deeplink as string | undefined) ?? null,
      checkoutUrl: (body.checkout_qr_url as string | undefined) ?? null,
    };
  }

  /** Check transaction (works for transactions created in the last 7 days). */
  async check(tranId: string): Promise<CheckResult> {
    this.ensureConfigured();
    if (this.mock) return { status: this.mockPaid.has(tranId) ? "APPROVED" : "PENDING", apv: "TEST00", raw: {} };
    const req_time = reqTime();
    const hash = this.hash([req_time, this.merchantId, tranId]);
    const body = await this.request("/api/payment-gateway/v1/payments/check-transaction-2", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ req_time, merchant_id: this.merchantId, tran_id: tranId, hash }),
    });
    const data = (body.data ?? {}) as Record<string, unknown>;
    const text = String(data.payment_status ?? "").toUpperCase();
    const code = data.payment_status_code;
    let status: PaywayStatus = "PENDING";
    if (text === "APPROVED" || text === "PRE-AUTH" || (text === "" && Number(code) === 0 && isOk((body.status as { code?: unknown })?.code))) status = "APPROVED";
    else if (["DECLINED", "CANCELLED", "REFUNDED"].includes(text)) status = "FAILED";
    return { status, apv: data.apv ? String(data.apv) : undefined, raw: body };
  }

  /**
   * PayWay signs its callback: values sorted by key, joined, HMAC-SHA512, base64,
   * sent in the X-PAYWAY-HMAC-SHA512 header.
   */
  verifyCallback(payload: Record<string, unknown>, signature: string | undefined) {
    if (!signature || !this.callbackSecret) return false;
    const data = Object.keys(payload)
      .sort()
      .map((k) => {
        const v = payload[k];
        if (v === null || v === undefined || v === false) return "";
        if (v === true) return "1";
        return typeof v === "object" ? JSON.stringify(v) : String(v);
      })
      .join("");
    const expected = createHmac("sha512", this.callbackSecret).update(data, "utf8").digest();
    const given = Buffer.from(signature, "base64");
    return given.length === expected.length && timingSafeEqual(given, expected);
  }

  private async request(path: string, init: RequestInit): Promise<Record<string, unknown>> {
    let res: Response;
    try {
      res = await fetch(`${this.baseUrl}${path}`, { ...init, signal: AbortSignal.timeout(20_000) });
    } catch (e) {
      this.log.error(`${path} unreachable: ${(e as Error).message}`);
      throw new BadGatewayException({ reason: "PAYWAY_UNREACHABLE", message: "Can't reach ABA PayWay right now" });
    }
    const text = await res.text();
    try {
      return JSON.parse(text) as Record<string, unknown>;
    } catch {
      this.log.error(`${path} HTTP ${res.status}, not JSON: ${text.slice(0, 200)}`);
      throw new BadGatewayException({ reason: "PAYWAY_BAD_RESPONSE", message: "ABA PayWay sent an unexpected answer" });
    }
  }
}

const isOk = (code: unknown) => code === 0 || code === "0" || code === "00";
