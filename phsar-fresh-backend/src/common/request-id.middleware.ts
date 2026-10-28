import { randomUUID } from "crypto";
import type { NextFunction, Request, Response } from "express";

/** Tags each request with an id (kept from X-Request-Id if a proxy set one) so errors can be traced in the logs. */
export function requestId(req: Request & { id?: string }, res: Response, next: NextFunction) {
  const incoming = req.header("x-request-id");
  req.id = incoming && /^[\w-]{8,64}$/.test(incoming) ? incoming : randomUUID();
  res.setHeader("X-Request-Id", req.id);
  next();
}
