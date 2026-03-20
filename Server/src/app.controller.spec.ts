import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';
import { ScannerService } from './scanner/scanner.service';
import { BadRequestException } from '@nestjs/common';

describe('AppController', () => {
  let appController: AppController;
  let scannerService: ScannerService;

  beforeEach(async () => {
    const mockScannerService = {
      queueRepositoryScan: jest.fn().mockResolvedValue('mock-message-id'),
    };

    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [
        {
          provide: ScannerService,
          useValue: mockScannerService,
        },
      ],
    }).compile();

    appController = app.get<AppController>(AppController);
    scannerService = app.get<ScannerService>(ScannerService);
  });

  describe('scanRepo', () => {
    it('should queue a scan and return a messageId', async () => {
      const result = await appController.scanRepo(
        'https://github.com/test/repo',
      );
      expect(result).toEqual({ messageId: 'mock-message-id' });
      // eslint-disable-next-line @typescript-eslint/unbound-method
      expect(scannerService.queueRepositoryScan).toHaveBeenCalledWith(
        'https://github.com/test/repo',
      );
    });

    it('should throw BadRequestException if repoUrl is missing', async () => {
      await expect(appController.scanRepo('')).rejects.toThrow(
        BadRequestException,
      );
    });
  });
});
