import { Controller, Post, Body, Get, Patch, Param, BadRequestException } from '@nestjs/common';
import { AppService, ScanJob } from './app.service';
import { ScannerService } from './scanner/scanner.service';

@Controller()
export class AppController {
  constructor(
    private readonly appService: AppService,
    private readonly scannerService: ScannerService
  ) { }

  @Get('hello')
  getHello() {
    return this.appService.getHello();
  }

  @Get('health')
  getHealth() {
    return {
      status: 'up',
      timestamp: new Date().toISOString(),
      service: 'Security Scanner API',
      memory: process.memoryUsage(),
    };
  }

  @Post('scan')
  async scanRepo(@Body('repoUrl') repoUrl: string) {
    if (!repoUrl) {
      throw new BadRequestException('repoUrl is required');
    }

    // 1. Queue the scan in Azure
    const messageId = await this.scannerService.queueRepositoryScan(repoUrl);

    // 2. Register the job in our temporary in-memory store
    this.appService.addJob({
      id: messageId,
      repoUrl,
      timestamp: new Date().toISOString(),
      status: 'pending',
      vulnerabilities: 0
    });

    return { messageId };
  }

  @Patch('scans/:id')
  async updateScan(@Param('id') id: string, @Body() update: Partial<ScanJob>) {
    this.appService.updateJob(id, update);
    return { success: true };
  }

  @Get('scans')
  async getScans() {
    return this.appService.getJobs();
  }
}
