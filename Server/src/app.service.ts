import { Injectable } from '@nestjs/common';


export interface ScanJob {
  id: string;
  repoUrl: string;
  timestamp: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  vulnerabilities: number;
}

@Injectable()
export class AppService {
  private scanJobs: ScanJob[] = [];

  addJob(job: ScanJob) {
    this.scanJobs.unshift(job);
  }

  getJobs(): ScanJob[] {
    return this.scanJobs;
  }

  updateJob(id: string, update: Partial<ScanJob>) {
    const job = this.scanJobs.find(j => j.id === id);
    if (job) {
      Object.assign(job, update);
    }
  }

  getHello(): string {
    return 'Security Scanner API Active';
  }
}
