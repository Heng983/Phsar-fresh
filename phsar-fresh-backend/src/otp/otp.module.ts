import { Module } from "@nestjs/common";
import { SmsModule } from "../sms/sms.module";
import { OtpService } from "./otp.service";

@Module({
  imports: [SmsModule],
  providers: [OtpService],
  exports: [OtpService],
})
export class OtpModule {}
