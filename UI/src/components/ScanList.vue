<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { 
  History, 
  ExternalLink, 
  AlertTriangle, 
  CheckCircle, 
  XCircle,
  Clock
} from 'lucide-vue-next';

interface ScanJob {
  id: string;
  repoUrl: string;
  timestamp: string;
  status: 'completed' | 'failed' | 'processing' | 'pending';
  vulnerabilities: number;
}

const recentScans = ref<ScanJob[]>([]);
const isLoading = ref(true);

const fetchScans = async () => {
  try {
    const apiBase = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000';
    const response = await fetch(`${apiBase}/scans`);
    if (response.ok) {
      recentScans.value = await response.json();
    }
  } catch (err) {
    console.error('Failed to fetch scans:', err);
  } finally {
    isLoading.value = false;
  }
};

onMounted(() => {
  fetchScans();
  // Poll for updates every 10 seconds
  setInterval(fetchScans, 10000);
});

const getStatusColor = (status: string) => {
  switch (status) {
    case 'completed': return 'text-success';
    case 'failed': return 'text-error';
    case 'processing': return 'text-accent-primary';
    case 'pending': return 'text-secondary';
    default: return 'text-secondary';
  }
};

const formatDate = (date: string) => {
  return new Intl.DateTimeFormat('en-US', {
    dateStyle: 'short',
    timeStyle: 'short'
  }).format(new Date(date));
};
</script>

<template>
  <div class="scans-container glass-card animate-fade-in" style="animation-delay: 0.2s">
    <div class="scans-header">
      <div class="flex items-center gap-2">
        <History class="w-5 h-5 text-accent-secondary" />
        <h3 class="font-heading text-lg">Recent Scan History</h3>
      </div>
      <button @click="fetchScans" class="btn-text">Refresh History</button>
    </div>

    <div v-if="isLoading" class="text-center py-8">
      <div class="animate-spin inline-block mr-2"><Clock /></div>
      <span>Loading history...</span>
    </div>

    <div v-else-if="recentScans.length === 0" class="text-center py-8 text-secondary">
      No scans recorded yet. Initiate your first scan above!
    </div>

    <div v-else class="scans-grid">
      <div v-for="scan in recentScans" :key="scan.id" class="scan-item">
        <div class="scan-main">
          <div class="repo-info">
            <span class="repo-name truncate">{{ scan.repoUrl.split('/').pop() }}</span>
            <span class="timestamp">{{ formatDate(scan.timestamp) }}</span>
          </div>
          <div class="scan-status" :class="getStatusColor(scan.status)">
            <CheckCircle v-if="scan.status === 'completed'" class="w-4 h-4" />
            <XCircle v-else-if="scan.status === 'failed'" class="w-4 h-4" />
            <Clock v-else class="w-4 h-4 animate-spin" />
            <span class="capitalize">{{ scan.status }}</span>
          </div>
        </div>
        
        <div class="scan-footer">
          <div class="vuln-count" :class="scan.vulnerabilities > 0 ? 'vuln-warning' : 'vuln-safe'">
            <AlertTriangle v-if="scan.vulnerabilities > 0" class="w-4 h-4" />
            <span>{{ scan.vulnerabilities }} Vulnerabilities Found</span>
          </div>
          <a :href="scan.repoUrl" target="_blank" class="repo-link">
            <ExternalLink class="w-4 h-4" />
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.scans-container {
  max-width: 900px;
  margin: 0 auto 4rem;
}

.scans-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  border-bottom: 1px solid var(--border);
  padding-bottom: 1rem;
}

.scans-grid {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.scan-item {
  background: rgba(0, 0, 0, 0.2);
  border: 1px solid var(--border);
  border-radius: 0.75rem;
  padding: 1rem;
  transition: all 0.2s ease;
}

.scan-item:hover {
  border-color: rgba(99, 102, 241, 0.3);
  transform: scale(1.005);
}

.scan-main {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 0.75rem;
}

.repo-info {
  display: flex;
  flex-direction: column;
}

.repo-name {
  font-weight: 600;
  font-size: 1.1rem;
  color: var(--text-primary);
  max-width: 300px;
}

.timestamp {
  font-size: 0.8rem;
  color: var(--text-secondary);
}

.scan-status {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  font-weight: 600;
}

.scan-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.vuln-count {
  padding: 0.25rem 0.75rem;
  border-radius: 999px;
  font-size: 0.8rem;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-weight: 500;
}

.vuln-warning {
  background: rgba(239, 68, 68, 0.1);
  color: var(--error);
}

.vuln-safe {
  background: rgba(34, 197, 94, 0.1);
  color: var(--success);
}

.repo-link {
  color: var(--text-secondary);
  transition: color 0.2s ease;
}

.repo-link:hover {
  color: var(--accent-primary);
}

.btn-text {
  background: transparent;
  color: var(--accent-primary);
  font-size: 0.9rem;
  padding: 0;
}

.btn-text:hover {
  text-decoration: underline;
}

.animate-spin {
  animation: spin 3s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.items-center { display: flex; align-items: center; }
.gap-2 { gap: 0.5rem; }
.text-lg { font-size: 1.125rem; }
.truncate { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.text-success { color: var(--success); }
.text-error { color: var(--error); }
.text-accent-primary { color: var(--accent-primary); }
</style>
