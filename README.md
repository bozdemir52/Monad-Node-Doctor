## Monad Node Doctor

A lightweight, zero-dependency bash script to instantly check if your Linux server is fully optimized for a high-performance Monad node.

High-throughput blockchains like Monad require specific OS-level tuning (like disabling SMT, changing CPU governors, and increasing file descriptors). This script diagnoses your node in seconds.

## Quick Start
Run the following command on your Monad node:
\`\`\`bash
curl -sO https://raw.githubusercontent.com/bozdemir52/monad-node-doctor/main/monad-doctor.sh
chmod +x monad-doctor.sh
./monad-doctor.sh
\`\`\`

## 🛠️ What it checks:
1. **CPU Cores:** Ensures you have 16+ physical cores.
2. **System RAM:** Checks for 32GB+ memory.
3. **SMT/Hyperthreading:** Verifies that logical threads are disabled to prevent context-switching lag.
4. **CPU Governor:** Ensures the CPU is set to 'performance' mode.
5. **Open File Limits:** Checks if `ulimit -n` is set to 1048576 for massive P2P/DB connections.
6. **NVMe Storage:** Confirms the presence of high-IOPS NVMe drives.
