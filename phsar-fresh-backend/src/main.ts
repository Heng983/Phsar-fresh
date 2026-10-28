import "reflect-metadata";
import { Logger, ValidationPipe } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";
import { NestExpressApplication } from "@nestjs/platform-express";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import compression from "compression";
import helmet from "helmet";
import { join } from "path";
import { AppModule } from "./app.module";
import { AllExceptionsFilter } from "./common/all-exceptions.filter";
import { requestId } from "./common/request-id.middleware";

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, { bodyParser: false });
  const prod = process.env.NODE_ENV === "production";

  // Behind ngrok / nginx / a load balancer: use the real client IP for rate
  // limits instead of the proxy's (otherwise every user shares one limit).
  // TRUST_PROXY = number of proxies in front (default 1 in production).
  const trustProxy = process.env.TRUST_PROXY ?? (prod ? "1" : "0");
  if (trustProxy !== "0") app.set("trust proxy", /^\d+$/.test(trustProxy) ? Number(trustProxy) : trustProxy);

  app.use(requestId);
  app.use(helmet({ crossOriginResourcePolicy: { policy: "cross-origin" } }));
  // gzip: product lists and order histories are ~5–10× smaller on mobile data.
  app.use(compression({ threshold: 1024 }));
  // Requests are small JSON; photos go through multipart (5 MB cap per route).
  app.useBodyParser("json", { limit: "200kb" });
  app.useBodyParser("urlencoded", { limit: "200kb", extended: true }); // PayWay's callback may post a form

  // The mobile app and the admin server don't need CORS. Only browsers do,
  // so list allowed web origins in CORS_ORIGINS (comma separated).
  const origins = (process.env.CORS_ORIGINS ?? "").split(",").map((o) => o.trim()).filter(Boolean);
  app.enableCors(origins.length ? { origin: origins, credentials: true } : prod ? { origin: false } : undefined);

  app.setGlobalPrefix("api/v1");
  app.enableShutdownHooks();
  app.useGlobalFilters(new AllExceptionsFilter());

  app.useStaticAssets(join(process.cwd(), "uploads"), {
    prefix: "/uploads",
    maxAge: "30d",
    immutable: true, // file names change when a photo is replaced
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  if (!prod) {
    const doc = new DocumentBuilder()
      .setTitle("Phsar Fresh API")
      .setVersion("1.0")
      .addBearerAuth()
      .build();
    SwaggerModule.setup("docs", app, SwaggerModule.createDocument(app, doc));
  }

  const port = Number(process.env.PORT ?? 3000);
  await app.listen(port);
  const log = new Logger("Bootstrap");
  log.log(`API:     http://localhost:${port}/api/v1`);
  if (!prod) log.log(`Swagger: http://localhost:${port}/docs`);
}
bootstrap();
