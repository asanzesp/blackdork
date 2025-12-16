#!/bin/bash

# Configuración del proyecto
readonly PROJECT_NAME="Blackdork"
readonly VERSION="1.0"
readonly AUTHOR="Redhex"

# Directorios
readonly BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_DIR="${BASE_DIR}/logs"
readonly TEMP_DIR="${BASE_DIR}/temp"

# Archivos
readonly LOG_FILE="${LOG_DIR}/app.log"

# Crear directorios necesarios
mkdir -p "$LOG_DIR" "$TEMP_DIR"

# Definir comandos requeridos
REQUIRED_COMMANDS=("awk" "cd" "curl" "dirname" "grep" "pwd" "sed" "sort")

# Configuración por defecto
USER_AGENTS_LIST=${USER_AGENTS_LIST:-"${BASE_DIR}/user_agents_list.txt"}
DOMAIN_QUERIES_LIST=${DOMAIN_QUERIES_LIST:-"${BASE_DIR}/queries_lists/domain_queries_list.txt"}
NAME_QUERIES_LIST=${NAME_QUERIES_LIST:-"${BASE_DIR}/queries_lists/name_queries_list.txt"}
COMPANY_QUERIES_LIST=${COMPANY_QUERIES_LIST:-"${BASE_DIR}/queries_lists/company_queries_list.txt"}
EMAIL_QUERIES_LIST=${EMAIL_QUERIES_LIST:-"${BASE_DIR}/queries_lists/email_queries_list.txt"}
USERNAME_QUERIES_LIST=${USERNAME_QUERIES_LIST:-"${BASE_DIR}/queries_lists/username_queries_list.txt"}
VERBOSE=${VERBOSE:-false}
CONNECT_TIMEOUT=${CONNECT_TIMEOUT:-15}
MAX_TIME=${MAX_TIME:-30}
