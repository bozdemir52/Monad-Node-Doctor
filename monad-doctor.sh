#!/bin/bash

# Renk Tanımlamaları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BLUE}${BOLD}"
echo "====================================================="
echo "   🩺 MONAD NODE DOCTOR - Performance & Health Check"
echo "====================================================="
echo -e "${NC}"

SCORE=0
TOTAL_CHECKS=7

# 1. CPU Core Check
echo -n -e "1. CPU Cores Check: "
CORES=$(nproc)
if [ "$CORES" -ge 16 ]; then
    echo -e "${GREEN}PASS ($CORES Cores)${NC}"
    SCORE=$((SCORE+1))
else
    echo -e "${YELLOW}WARN ($CORES Cores - 16+ Recommended)${NC}"
fi

# 2. CPU Frequency (Clock Speed) Check
echo -n -e "2. CPU Clock Speed Check: "
# lscpu'dan Max MHz çekmeyi dener, bulamazsa anlık çalışan en yüksek MHz'yi alır
CPU_MAX_MHZ=$(lscpu | grep "CPU max MHz" | awk '{print $4}' | cut -d. -f1)
if [ -z "$CPU_MAX_MHZ" ]; then
    CPU_MAX_MHZ=$(grep "cpu MHz" /proc/cpuinfo | awk '{print $4}' | sort -nr | head -n1 | cut -d. -f1)
fi

if [ -n "$CPU_MAX_MHZ" ]; then
    CPU_GHZ=$(awk "BEGIN {printf \"%.1f\", $CPU_MAX_MHZ/1000}")
    if [ "$CPU_MAX_MHZ" -ge 4500 ]; then
        echo -e "${GREEN}PASS (${CPU_GHZ} GHz)${NC}"
        SCORE=$((SCORE+1))
    elif [ "$CPU_MAX_MHZ" -ge 3500 ]; then
        echo -e "${YELLOW}WARN (${CPU_GHZ} GHz - Docs recommend 4.5GHz+ for maximum TPS)${NC}"
        # Puan kırmıyoruz ama uyarıyoruz, çünkü bazı bulut sunucularda 4.5 zor bulunuyor.
        SCORE=$((SCORE+1)) 
    else
        echo -e "${RED}FAIL (${CPU_GHZ} GHz - Might be too slow for Monad!)${NC}"
    fi
else
    echo -e "${YELLOW}WARN (Could not read CPU MHz. VM/VPS restriction?)${NC}"
    SCORE=$((SCORE+1)) # Sanal sunucu kısıtlaması olabilir, puan kırmayalım.
fi

# 3. System RAM Check
echo -n -e "3. System RAM Check: "
RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RAM_GB=$((RAM_KB / 1024 / 1024))
if [ "$RAM_GB" -ge 31 ]; then
    echo -e "${GREEN}PASS (${RAM_GB}GB)${NC}"
    SCORE=$((SCORE+1))
else
    echo -e "${YELLOW}WARN (${RAM_GB}GB - 32GB+ Recommended)${NC}"
fi

# 4. SMT / Hyperthreading Check
echo -n -e "4. SMT/Hyperthreading Status: "
if [ -f /sys/devices/system/cpu/smt/control ]; then
    SMT_STATUS=$(cat /sys/devices/system/cpu/smt/control)
    if [ "$SMT_STATUS" == "off" ]; then
        echo -e "${GREEN}PASS (Disabled - Good for Monad)${NC}"
        SCORE=$((SCORE+1))
    else
        echo -e "${RED}FAIL (Enabled - Can cause context-switching lag!)${NC}"
    fi
else
    echo -e "${YELLOW}WARN (SMT control not found)${NC}"
    SCORE=$((SCORE+1))
fi

# 5. CPU Governor Check
echo -n -e "5. CPU Governor Mode: "
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
    GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    if [ "$GOV" == "performance" ]; then
        echo -e "${GREEN}PASS (Performance Mode)${NC}"
        SCORE=$((SCORE+1))
    else
        echo -e "${RED}FAIL (Current: $GOV - Should be 'performance')${NC}"
    fi
else
    echo -e "${YELLOW}WARN (Governor info not available)${NC}"
    SCORE=$((SCORE+1))
fi

# 6. Open File Limit (ulimit)
echo -n -e "6. Open File Limits: "
ULIMIT=$(ulimit -n)
if [ "$ULIMIT" -ge 1000000 ]; then
    echo -e "${GREEN}PASS ($ULIMIT)${NC}"
    SCORE=$((SCORE+1))
else
    echo -e "${RED}FAIL ($ULIMIT - Should be 1048576 for P2P/DB)${NC}"
fi

# 7. NVMe Check
echo -n -e "7. NVMe Storage Check: "
if lsblk | grep -q "nvme"; then
    echo -e "${GREEN}PASS (NVMe drive detected)${NC}"
    SCORE=$((SCORE+1))
else
    echo -e "${YELLOW}WARN (No NVMe detected - Monad requires high IOPS)${NC}"
fi

echo ""
echo -e "${BLUE}=====================================================${NC}"

# Final Karar
if [ "$SCORE" -eq "$TOTAL_CHECKS" ]; then
    echo -e "${GREEN}${BOLD}🎉 RESULT: EXCELLENT! Your node is perfectly optimized for Monad.${NC}"
elif [ "$SCORE" -ge 4 ]; then
    echo -e "${YELLOW}${BOLD}⚠️ RESULT: GOOD, but needs attention. Fix the red/yellow lines for maximum TPS.${NC}"
else
    echo -e "${RED}${BOLD}🚨 RESULT: POOR. Your node might struggle to keep up with the Monad network!${NC}"
fi
echo -e "${BLUE}=====================================================${NC}"
