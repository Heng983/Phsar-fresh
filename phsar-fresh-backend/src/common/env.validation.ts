/**
 * Checked once at startup so a missing or weak setting stops the server with a
 * clear message, instead of failing later on a customer's request.
 */
export function validateEnv(env: Record<string, unknown>) {
  const missing = ["DATABASE_URL", "REDIS_URL", "JWT_ACCESS_SECRET", "OTP_SECRET"].filter(
    (key) => typeof env[key] !== "string" || !(env[key] as string).trim(),
  );
  if (missing.length) throw new Error(`Missing in .env: ${missing.join(", ")}`);

  if (env.NODE_ENV === "production") {
    const weak = ["JWT_ACCESS_SECRET", "OTP_SECRET"].filter((key) => (env[key] as string).length < 32);
    if (weak.length) {
      throw new Error(`${weak.join(", ")} must be at least 32 random characters in production (e.g. openssl rand -base64 48)`);
    }
    if (env.PAYWAY_MOCK === "true") {
      console.warn("⚠ PAYWAY_MOCK=true in production: payments are simulated.");
    }
  }
  return env;
}
