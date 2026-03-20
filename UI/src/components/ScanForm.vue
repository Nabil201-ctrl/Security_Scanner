<script setup lang="ts">
import { ref } from 'vue';
import { ShieldCheck, Search, Loader2 } from 'lucide-vue-next';

const repoUrl = ref('');
const isScanning = ref(false);
const showMessage = ref(false);
const errorMessage = ref('');

const handleSubmit = async () => {
  if (!repoUrl.value) return;
  
  if (!repoUrl.value.startsWith('https://github.com/')) {
    errorMessage.value = 'Only GitHub repositories are supported.';
    return;
  }
  
  errorMessage.value = '';
  isScanning.value = true;
  
  try {
    const apiBase = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000';
    const response = await fetch(`${apiBase}/scan`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ repoUrl: repoUrl.value })
    });
    
    if (!response.ok) throw new Error('API failed');

    showMessage.value = true;
    setTimeout(() => showMessage.value = false, 3000);
    repoUrl.value = '';
  } catch (err) {
    errorMessage.value = 'Failed to queue scan. Make sure the server is running.';
  } finally {
    isScanning.value = false;
  }
};
</script>

<template>
  <div class="scan-form-container glass-card animate-fade-in">
    <div class="form-header">
      <div class="icon-pulse">
        <ShieldCheck class="w-8 h-8 text-accent-primary" />
      </div>
      <h2>Initiate Security Scan</h2>
      <p>Analyze your GitHub repository for vulnerabilities, leaked keys, and misconfigurations.</p>
    </div>

    <form @submit.prevent="handleSubmit" class="form-group">
      <div class="input-wrapper">
        <Search class="search-icon w-5 h-5" />
        <input 
          v-model="repoUrl"
          type="url" 
          placeholder="https://github.com/user/repo" 
          required
          :disabled="isScanning"
        />
      </div>
      
      <button 
        type="submit" 
        class="submit-btn btn-primary"
        :disabled="isScanning || !repoUrl"
      >
        <span v-if="!isScanning">Scan Now</span>
        <Loader2 v-else class="animate-spin" />
      </button>
    </form>
    
    <div v-if="errorMessage" class="message-error animate-fade-in">
      {{ errorMessage }}
    </div>
    
    <div v-if="showMessage" class="message-success animate-fade-in">
      Scan successfully queued! Job ID assigned.
    </div>
  </div>
</template>

<style scoped>
.scan-form-container {
  max-width: 700px;
  margin: 3rem auto;
  text-align: center;
}

.form-header h2 {
  margin: 1rem 0 0.5rem;
  font-size: 1.8rem;
  color: var(--text-primary);
}

.form-header p {
  color: var(--text-secondary);
  font-size: 0.95rem;
  margin-bottom: 2rem;
}

.form-group {
  display: flex;
  gap: 1rem;
}

.input-wrapper {
  position: relative;
  flex: 1;
}

.search-icon {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-secondary);
  pointer-events: none;
}

input {
  padding-left: 3rem !important;
}

.submit-btn {
  white-space: nowrap;
  min-width: 140px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.message-success {
  margin-top: 1.5rem;
  color: var(--success);
  font-weight: 500;
  font-size: 0.9rem;
}

.message-error {
  margin-top: 1.5rem;
  color: var(--error);
  font-weight: 500;
  font-size: 0.9rem;
}

.icon-pulse {
  background: rgba(99, 102, 241, 0.1);
  width: 64px;
  height: 64px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% { box-shadow: 0 0 0 0 rgba(99, 102, 241, 0.4); }
  70% { box-shadow: 0 0 0 15px rgba(99, 102, 241, 0); }
  100% { box-shadow: 0 0 0 0 rgba(99, 102, 241, 0); }
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>
