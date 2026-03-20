import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ScannerService } from './scanner/scanner.service';

@Module({
  imports: [],
  controllers: [AppController],
  providers: [AppService, ScannerService],
})
export class AppModule {}
