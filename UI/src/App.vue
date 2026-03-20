<script setup lang="ts">
import ScanForm from './components/ScanForm.vue';
import ScanList from './components/ScanList.vue';
import { Shield, Zap, Globe, Github } from 'lucide-vue-next';
</script>

<template>
  <div class="app-layout">
    <!-- Navbar -->
    <header class="navbar">
      <div class="container flex justify-between items-center">
        <div class="logo-group flex items-center gap-3">
          <div class="logo-icon glass-card">
            <Shield class="w-6 h-6 text-accent-primary" />
          </div>
          <h1 class="font-heading text-xl gradient-text">SEC-SCANNER</h1>
        </div>
        
        <nav class="desktop-nav">
          <a href="#" class="nav-link active">Dashboard</a>
          <a href="#" class="nav-link">Reports</a>
          <a href="#" class="nav-link">Settings</a>
        </nav>
        
        <div class="nav-actions">
          <a href="https://github.com/nabil-abubakar/Security_Scanner" target="_blank" class="github-button glass-card">
            <Github class="w-5 h-5" />
            <span>GitHub</span>
          </a>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="container">
      <!-- Hero Section -->
      <section class="hero-section text-center animate-fade-in">
        <div class="badge-accent glass-card">v1.2.0 ALPHA</div>
        <h2 class="text-5xl font-heading mb-4">
          Automated GitHub <br /> 
          <span class="gradient-text">Security Audits</span>
        </h2>
        <p class="hero-subtext">
          Enterprise-grade static analysis for repositories. <br />
          Instant vulnerability detection for modern dev teams.
        </p>
      </section>

      <!-- Stats Grid -->
      <section class="stats-grid animate-fade-in" style="animation-delay: 0.1s">
        <div class="stat-card glass-card">
          <Zap class="stat-icon text-yellow-500" />
          <div class="stat-content">
            <span class="stat-label">Fast Scanning</span>
            <span class="stat-value">< 1min Average</span>
          </div>
        </div>
        <div class="stat-card glass-card">
          <Shield class="stat-icon text-green-500" />
          <div class="stat-content">
            <span class="stat-label">Vulnerabilities</span>
            <span class="stat-value">500+ Rules</span>
          </div>
        </div>
        <div class="stat-card glass-card">
          <Globe class="stat-icon text-blue-500" />
          <div class="stat-content">
            <span class="stat-label">Cloud Native</span>
            <span class="stat-value">Azure Queue Powered</span>
          </div>
        </div>
      </section>

      <!-- Core Features -->
      <div class="grid-content">
        <ScanForm />
        <ScanList />
      </div>
    </main>

    <!-- Footer -->
    <footer class="footer">
      <div class="container text-center">
        <p class="text-sm text-secondary">
          &copy; 2026 Security_Scanner. Built for high-speed audits. 
          <span class="mx-2">|</span> 
          Powered by Azure Storage Queues.
        </p>
      </div>
    </footer>
    
    <!-- Decorative Gradients -->
    <div class="blob blob-1"></div>
    <div class="blob blob-2"></div>
  </div>
</template>

<style scoped>
.app-layout {
  position: relative;
  min-height: 100vh;
  overflow: hidden;
}

.navbar {
  padding: 1.5rem 0;
  border-bottom: 1px solid var(--border);
  background: rgba(10, 11, 30, 0.7);
  backdrop-filter: blur(8px);
  position: sticky;
  top: 0;
  z-index: 50;
}

.logo-icon {
  padding: 0.5rem;
  border-radius: 0.5rem;
}

.nav-link {
  color: var(--text-secondary);
  text-decoration: none;
  font-weight: 500;
  padding: 0.5rem 1rem;
  font-size: 0.9rem;
  transition: all 0.2s ease;
}

.nav-link:hover, .nav-link.active {
  color: var(--text-primary);
}

.github-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  text-decoration: none;
  color: var(--text-primary);
  font-size: 0.85rem;
}

.desktop-nav {
  display: flex;
  gap: 1.5rem;
}

.hero-section {
  padding: 4rem 0 3rem;
}

.badge-accent {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  font-size: 0.7rem;
  font-weight: 700;
  letter-spacing: 0.1em;
  color: var(--accent-primary);
  border-radius: 999px;
  margin-bottom: 2rem;
}

.text-5xl { font-size: 3.5rem; line-height: 1.1; }
.hero-subtext {
  color: var(--text-secondary);
  font-size: 1.1rem;
  max-width: 600px;
  margin: 0 auto;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
}

.stat-icon {
  width: 2rem;
  height: 2rem;
}

.stat-content {
  display: flex;
  flex-direction: column;
}

.stat-label {
  font-size: 0.75rem;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.stat-value {
  font-weight: 700;
  font-size: 1.1rem;
}

.footer {
  padding: 2rem 0;
  border-top: 1px solid var(--border);
  margin-top: 4rem;
}

/* Background Decorations */
.blob {
  position: absolute;
  width: 600px;
  height: 600px;
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.1), rgba(168, 85, 247, 0.1));
  filter: blur(100px);
  border-radius: 50%;
  z-index: -1;
  pointer-events: none;
}

.blob-1 {
  top: -100px;
  right: -100px;
}

.blob-2 {
  bottom: -200px;
  left: -200px;
}

/* Helper Utilities */
.flex { display: flex; }
.flex-col { flex-direction: column; }
.justify-between { justify-content: space-between; }
.items-center { align-items: center; }
.gap-3 { gap: 0.75rem; }
.mb-4 { margin-bottom: 1rem; }
.text-center { text-align: center; }
.text-sm { font-size: 0.875rem; }
.text-xl { font-size: 1.25rem; }
.mx-2 { margin-left: 0.5rem; margin-right: 0.5rem; }
.text-yellow-500 { color: #f59e0b; }
.text-green-500 { color: #22c55e; }
.text-blue-500 { color: #3b82f6; }

@media (max-width: 768px) {
  .stats-grid { grid-template-columns: 1fr; }
  .desktop-nav { display: none; }
  .text-5xl { font-size: 2.5rem; }
}
</style>
