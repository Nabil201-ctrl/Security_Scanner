// src/scanner/scanner.service.ts
import { Injectable, BadRequestException } from '@nestjs/common';
import { QueueClient } from '@azure/storage-queue';
import { DefaultAzureCredential } from '@azure/identity';

@Injectable()
export class ScannerService {
  private queueClient: QueueClient;

  constructor() {
    // Production: Use Managed Identity instead of Connection Strings
    const accountName = process.env.AZURE_STORAGE_ACCOUNT_NAME;
    this.queueClient = new QueueClient(
      `https://${accountName}.queue.core.windows.net/scan-jobs`,
      new DefaultAzureCredential(),
    );
  }

  async queueRepositoryScan(repoUrl: string): Promise<string> {
    // 1. Basic URL Validation
    if (!repoUrl.startsWith('https://github.com/')) {
      throw new BadRequestException('Only GitHub repositories are supported');
    }

    // 2. Metadata for the worker
    const jobPayload = JSON.stringify({
      repoUrl,
      timestamp: new Date().toISOString(),
      priority: 'normal',
    });

    const encodedMessage = Buffer.from(jobPayload).toString('base64');
    const response = await this.queueClient.sendMessage(encodedMessage);

    return response.messageId;
  }
}
