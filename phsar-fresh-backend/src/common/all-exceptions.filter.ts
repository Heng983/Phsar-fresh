import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus, Logger } from "@nestjs/common";
import { Prisma } from "@prisma/client";
import type { Request, Response } from "express";

/**
 * Every error leaves the API in the same shape the app and admin already read:
 *   { statusCode, message, error, requestId }
 * - HttpExceptions (400, 401, 403, 404, 409, 429…) pass through unchanged.
 * - Database errors get the right status instead of a bare 500
 *   (duplicate → 409, missing row → 404, DB busy/down → 503).
 * - Anything unexpected is logged with its stack, and the client only sees
 *   "Something went wrong" plus a requestId to find it in the logs.
 */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly log = new Logger("Errors");

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse<Response>();
    const req = ctx.getRequest<Request & { id?: string }>();
    if (res.headersSent) return;
    const requestId = req.id;

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const body = exception.getResponse();
      const payload = typeof body === "string" ? { statusCode: status, message: body } : (body as Record<string, unknown>);
      if (status >= 500) this.log.error(`${req.method} ${req.originalUrl} → ${status} [${requestId}] ${exception.message}`, exception.stack);
      return res.status(status).json({ ...payload, statusCode: status, requestId });
    }

    const mapped = mapDatabaseError(exception);
    if (mapped) {
      if (mapped.status >= 500) this.log.error(`${req.method} ${req.originalUrl} → ${mapped.status} [${requestId}] ${describe(exception)}`);
      else this.log.warn(`${req.method} ${req.originalUrl} → ${mapped.status} [${requestId}] ${describe(exception)}`);
      return res.status(mapped.status).json({ statusCode: mapped.status, message: mapped.message, error: mapped.error, requestId });
    }

    this.log.error(
      `${req.method} ${req.originalUrl} → 500 [${requestId}] ${describe(exception)}`,
      exception instanceof Error ? exception.stack : undefined,
    );
    return res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
      statusCode: 500,
      message: "Something went wrong. Please try again.",
      error: "Internal Server Error",
      requestId,
    });
  }
}

const describe = (e: unknown) =>
  e instanceof Prisma.PrismaClientKnownRequestError ? `${e.code} ${e.message.split("\n").at(-1)}` : e instanceof Error ? e.message : String(e);

function mapDatabaseError(e: unknown): { status: number; message: string; error: string } | null {
  if (e instanceof Prisma.PrismaClientKnownRequestError) {
    switch (e.code) {
      case "P2002": // unique constraint
        return { status: 409, message: "This already exists", error: "Conflict" };
      case "P2025": // record to update/delete not found
      case "P2001":
        return { status: 404, message: "Not found", error: "Not Found" };
      case "P2003": // foreign key
        return { status: 409, message: "This is still used somewhere else", error: "Conflict" };
      case "P2000": // value too long
        return { status: 400, message: "A value is too long", error: "Bad Request" };
      case "P2034": // write conflict / deadlock: safe to retry
        return { status: 409, message: "Busy right now — please try again", error: "Conflict" };
      case "P2024": // connection pool timeout
      case "P1001":
      case "P1002":
      case "P1017":
        return { status: 503, message: "Service is busy. Please try again in a moment.", error: "Service Unavailable" };
    }
    return null;
  }
  if (e instanceof Prisma.PrismaClientInitializationError || e instanceof Prisma.PrismaClientRustPanicError) {
    return { status: 503, message: "Service is busy. Please try again in a moment.", error: "Service Unavailable" };
  }
  // Redis (ioredis) down or slow.
  if (e instanceof Error && /ECONNREFUSED|ETIMEDOUT|Connection is closed|MaxRetriesPerRequest/i.test(e.message)) {
    return { status: 503, message: "Service is busy. Please try again in a moment.", error: "Service Unavailable" };
  }
  return null;
}
