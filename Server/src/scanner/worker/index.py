# worker.py
import os
import json
import base64
import tempfile
import subprocess
import logging
import requests
from azure.storage.queue import QueueClient
from azure.identity import DefaultAzureCredential

# Setup Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

API_URL = os.getenv("API_URL", "http://localhost:3000")

def update_scan_status(job_id, status, vulnerabilities=0):
    try:
        url = f"{API_URL}/scans/{job_id}"
        requests.patch(url, json={"status": status, "vulnerabilities": vulnerabilities})
    except Exception as e:
        logger.error(f"Failed to update scan status for {job_id}: {e}")

def run_security_scan(path):
    """Run multiple scanners: Bandit for code, Safety for deps."""
    results = {}
    vulnerabilities = 0
    try:
        # Bandit for Python source code analysis
        bandit = subprocess.run(["bandit", "-r", path, "-f", "json"], capture_output=True, text=True)
        if bandit.stdout:
            data = json.loads(bandit.stdout)
            results['static_analysis'] = data
            vulnerabilities += len(data.get('results', []))

        # Safety for dependency vulnerabilities
        safety = subprocess.run(["safety", "check", "--directory", path, "--json"], capture_output=True, text=True)
        if safety.stdout:
            data = json.loads(safety.stdout)
            results['dependency_vulnerabilities'] = data
            vulnerabilities += len(data) if isinstance(data, list) else 0
            
    except Exception as e:
        logger.error(f"Scan failed: {e}")
    return results, vulnerabilities

def main():
    account_url = f"https://{os.getenv('AZURE_STORAGE_ACCOUNT_NAME')}.queue.core.windows.net"
    queue_client = QueueClient(account_url, "scan-jobs", credential=DefaultAzureCredential())

    logger.info("Worker started, listening for messages...")
    while True:
        messages = queue_client.receive_messages(max_messages=1, visibility_timeout=300)
        for msg in messages:
            try:
                data = json.loads(base64.b64decode(msg.content).decode('utf-8'))
                repo_url = data['repoUrl']
                job_id = msg.id
                
                logger.info(f"Processing Job {job_id}: {repo_url}")
                update_scan_status(job_id, 'processing')
                
                with tempfile.TemporaryDirectory() as tmpdir:
                    logger.info(f"Cloning {repo_url} into {tmpdir}")
                    subprocess.run(["git", "clone", "--depth", "1", repo_url, tmpdir], check=True)
                    
                    report, vuln_count = run_security_scan(tmpdir)
                    update_scan_status(job_id, 'completed', vuln_count)
                    logger.info(f"Scan Complete for {repo_url} - Found {vuln_count} items")

                queue_client.delete_message(msg)
            except Exception as e:
                logger.error(f"Error processing message: {e}")
                if 'job_id' in locals():
                    update_scan_status(job_id, 'failed')

if __name__ == "__main__":
    main()