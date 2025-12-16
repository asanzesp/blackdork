#!/bin/bash

# Colores para logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
  echo -e "\n${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
  echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "${LOG_FILE}"
}

log_error() {
  echo -e "\n${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
  echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "${LOG_FILE}"
}

log_warning() {
  echo -e "\n${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
  echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "${LOG_FILE}"
}

log_success() {
  echo -e "\n${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
  echo "[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "${LOG_FILE}"
}
