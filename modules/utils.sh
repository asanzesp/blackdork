#!/bin/bash

function is_valid_proxy_url() {
  local proxy_url="$1"

  if [[ -z "$proxy_url" ]]; then
    log_error "The proxy URL cannot be empty"
    return 1
  fi

  local port=0

  if [[ "$proxy_url" =~ ^((http|https|socks4|socks4a|socks5|socks5h)://)?([a-zA-Z0-9\.-]+|\[[a-fA-F0-9:]+\]):([0-9]+)$ ]]; then
    port=${BASH_REMATCH[4]}
  else
    log_error "The proxy URL format $proxy_url is not valid"
    return 1
  fi

  if (( port >= 1 && port <= 65535 )); then
    return 0
  else
    log_error "The port $port is not a valid number. The port must be between 1 and 65535."
    return 1
  fi
}

function get_proxy_url_protocol() {
  local proxy_url="$1"
  local protocol=""

  if [[ "$proxy_url" =~ ^((http|https|socks4|socks4a|socks5|socks5h)://) ]]; then
    protocol="${BASH_REMATCH[2]}"
  else
    # If no protocol is specified, "http" is assumed
    protocol="http"
  fi
  
  echo "$protocol"
}

function create_file_output() {
  local type="$1"
  local path="$2"

  if verify_file_output_creation "$type" "$path"; then
  
    case "$type" in
      "normal")
        printf "%s\n" "${NORMAL_OUTPUT[@]}" >> "$path"
        ;;
      "xml")
        printf "%s\n" "${XML_OUTPUT[@]}" >> "$path"
        ;;
    esac
  
    if [ "$VERBOSE" = true ]; then
      echo "Read data files from: $BASE_DIR/$path"
    fi
  
  fi
}

function verify_file_output_creation() {
  local type="$1"
  local path="$2"
  local parent_path="$(dirname "$path")"
  
  # Check if the parent path exists
  if [ ! -d "$parent_path" ]; then
    log_error "Failed to open $type output file $path for writing: No such file or directory"
    return 1
  fi
  
  # Check write permissions on the directory
  if [ ! -w "$parent_path" ]; then
    log_error "Failed to open $type output file $path for writing"
    return 1
  fi
  
  if [ -f "$path" ]; then
    rm "$path"
  fi
    
  return 0
}

function check_dependencies() {
  local deps_name=$1
  local -n deps=$deps_name
  
  local missing=()
    
  for dep in "${deps[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
      missing+=("$dep")
    fi
  done
    
  if [ ${#missing[@]} -gt 0 ]; then
    log_error "Missing dependencies: ${missing[*]}"
    return 1
  fi
    
  return 0
}

function is_valid_file() {
  local file_path="$1"
    
  if [ ! -f "$file_path" ]; then
    log_error "File not found: $file_path"
    return 1
  fi
    
  if [ ! -r "$file_path" ]; then
    log_error "No read permissions: $file_path"
    return 1
  fi
    
  return 0
}

function get_current_timestamp() {
  date +"%s%3N"
}

function get_current_datetime_with_time_zone() {
  date +"%Y-%m-%d %H:%M %Z"
}

function get_current_datetime() {
  date +"%a %b %d %H:%M:%S %Y"
}

function get_elapsed_seconds() {
  local start_timestamp="$1"
  
  elapsed_seconds=$(( $(get_current_timestamp) - "$start_timestamp" ))
  
  local seconds=$((elapsed_seconds / 1000))
  local milliseconds=$((elapsed_seconds % 1000))
  
  echo "$seconds.$milliseconds"
}

function get_project_name_lowercase() {
  project_name=$PROJECT_NAME
  echo "${project_name,,}"
}

function is_valid_domain() {
  local domain="$1"
  
  # Pattern to validate domains (including internationalized ones)
  local pattern="^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$"
  
  # Check maximum total length (253 characters)
  [ "${#domain}" -gt 253 ] && return 1
  
  # Check for a match with the pattern
  [[ "$domain" =~ $pattern ]] || return 1
  
  # Check that TLDs are not entirely numeric
  local tld="${domain##*.}"
  [[ "$tld" =~ [a-zA-Z] ]] || return 1

  return 0
}

function is_valid_name() {
  local name="$1"
  local pattern="^[[:alpha:]' -]+$"

  if [[ -z "$name" ]]; then
    log_error "The name cannot be empty"
    return 1
  elif [[ ${#name} -lt 2 ]]; then
    log_error "The name is too short"
    return 1
  elif [[ ${#name} -gt 100 ]]; then
    log_error "The name is too long"
    return 1
  elif ! [[ "$name" =~ $pattern ]]; then
    log_error "Invalid name. Only letters, spaces, apostrophes (') and hyphens (-) are allowed."
    return 1
  else
    return 0
  fi
}

function is_valid_company_name() {
  local company_name="$1"
  local pattern="^[[:alnum:]&.,'() -]+$"

  if [[ -z "$company_name" ]]; then
    log_error "The company name cannot be empty"
    return 1
  elif [[ ${#company_name} -lt 2 ]]; then
    log_error "The company name is too short"
    return 1
  elif [[ ${#company_name} -gt 100 ]]; then
    log_error "The company name is too long"
    return 1
  elif ! [[ "$company_name" =~ $pattern ]]; then
    log_error "Invalid company name. Only letters, numbers, spaces, and the following symbols are allowed: & . , ' ( ) -."
    return 1
  else
    return 0
  fi
}

function is_valid_email() {
  local email="$1"

  local regex='^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'

  if [[ -z "$email" ]]; then
    log_error "The email cannot be empty"
    return 1
  fi

  if ! [[ "$email" =~ $regex ]]; then
    log_error "Invalid email: $email"
    return 1
  else
    return 0
 fi 
}

function is_valid_username() {
  local username="$1"

  local regex='^[A-Za-z][A-Za-z0-9_-]{2,31}$'

  if [[ -z "$username" ]]; then
    log_error "The username cannot be empty"
    return 1
  fi

  if ! [[ "$username" =~ $regex ]]; then
    log_error "Invalid username: $username"
    return 1      
  else
    return 0
  fi
}

function get_queries_list() {
  local queries_list_path="$1"
  
  is_valid_file $queries_list_path

  # Filter lines that do not start with # and are not empty
  mapfile -t queries < <(grep -v "^#" "$queries_list_path" | grep -v "^$")
}

function get_random_user_agent() {
  local user_agents_path="$1"

  is_valid_file "$user_agents_path"
  
  # Filter lines that do not start with # and are not empty
  mapfile -t user_agents < <(grep -v "^#" "$user_agents_path" | grep -v "^$")

  # Select a random User-Agent
  local random_index=$((RANDOM % ${#user_agents[@]}))
  
  user_agent="${user_agents[$random_index]}"

  echo "$user_agent"
}

function get_URLs() {
  query="${1%;}"
  proxy_url="$2"
  proxy_option=""
  
  if [ -n "$proxy_url" ]; then
    if is_valid_proxy_url "$proxy_url"; then
      
      protocol=$(get_proxy_url_protocol)
      
      case "$protocol" in
        http | https)
        proxy_option="--proxy $proxy_url"
        ;;
        socks4)
        echo "--socks4"
        proxy_option="--socks4 $proxy_url"
        ;;
        socks4a)
        echo "--socks4a"
        proxy_option="--socks4a $proxy_url"
        ;;
        socks5)
        echo "--socks5"
        proxy_option="--socks5 $proxy_url"
        ;;
        socks5h)
        echo "--socks5h"
        proxy_option="--socks5h $proxy_url"
        ;;
      esac
    fi
  fi
  
  random_user_agent=$(get_random_user_agent "$USER_AGENTS_LIST")

  declare -a options=(
    "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"
    "Accept-Language: en-US,en;q=0.5"
    "Accept-Encoding: gzip, deflate, br"
    "Connection: keep-alive"
    "Upgrade-Insecure-Requests: 1"
  )

  #printf '%s\n' "${options[@]}"
  
  echo -e $'\n'"Query -> $query"

  NORMAL_OUTPUT+=("Query -> $query")

  XML_OUTPUT+=("<search>")
  XML_OUTPUT+=("<query>$query</query>")
  XML_OUTPUT+=("<results>")
    
  get_query="q=$query"
  
  local timeout_options="--connect-timeout $CONNECT_TIMEOUT --max-time $MAX_TIME"
  
  if [ "$proxy_option" != "" ]; then
    response=$(curl -sL --compressed -A "$proxy_option" "$random_user_agent" -H "${options[0]}" -H "${options[1]}" -H "${options[2]}" -H "${options[3]}" -H "${options[4]}" $timeout_options --get --data-urlencode "$get_query" "https://startpage.com/sp/search")
  else
    response=$(curl -sL --compressed -A "$random_user_agent" -H "${options[0]}" -H "${options[1]}" -H "${options[2]}" -H "${options[3]}" -H "${options[4]}" $timeout_options --get --data-urlencode "$get_query" "https://startpage.com/sp/search")
  fi  
  
  #echo "$response"
  
  if [ $? -ne 0 ]; then
    log_error "cURL failed for query: $query (Check connection, proxy, or timeout settings)."
    # Optionally, exit the function here.
    # return 1
  fi
  
  if [ -z "$response" ]; then
    log_error "Received empty response for query: $query (Possible block by Startpage/Google)."
    # Optionally, exit the function here.
    # return 1
  fi  
  
  mapfile -t urls < <(echo "$response" | tr -d '\n\t' | grep -oE "href=\"(https?|ftp|file|mailto|tel|ws|wss):[^\"?#]+" | sed 's/href="//' | sed -E 's/[^A-Za-z0-9.:\/\?#\-~&_=;%]+$//' | sort -u | grep -vE 'startpage|tartpageSearch')
  
  NUM_OF_RESULTS+=${#urls[@]}
 
  if [ -n "$urls" ]; then
    for url in "${urls[@]}"; do
      
      echo "$url"
      
      NORMAL_OUTPUT+=("$url")
      
      XML_OUTPUT+=("<url>$url</url>")
      
    done
  fi
  
  XML_OUTPUT+=("</results>")
  XML_OUTPUT+=("</search>")
}

function get_help() {
  cat << EOF
${PROJECT_NAME} ${VERSION} ( https://github.com/blackdork )
Usage: blackdork [Target Selection] [Options]
TARGET SPECIFICATION:
  Pass a single target type. If multiple are provided, only the highest priority
  will be scanned (Domain > Name > Company > Email > Username).
  -d, --domain <domain>     Target a specific domain (e.g., example.com)
  -n, --name <name>         Target a person's full name (e.g., "Jhon Smith")
  -c, --company <company>   Target a specific company name
  -e, --email <email>       Target a specific email address
  -u, --username <username> Target a specific username/handle
SCAN CONFIGURATION:
  -f, --file <filename>     Input from custom list of queries (replaces defaults).
                            The file must use "TARGET" as a placeholder.
  --proxy <url>             Relay connections through HTTP/SOCKS proxy
                            (e.g., http://127.0.0.1:8080)
OUTPUT:
  -oN, --outputNormal <file> Output scan in normal text format to the given filename.
  -oX, --outputXML <file>    Output scan in XML format to the given filename.
  -oA, --outputAll <base>    Output in the two major formats at once.
                             Extensions .blackdork and .xml are appended.
  -v, --verbose              Increase verbosity level (shows queries as they run)
MISC:
  -h, --help                 Print this help summary page.
EXAMPLES:
  blackdork -d example.com -v
  blackdork --name "Jhon Smith" -oA jhon_smith_scan
  blackdork -c "Evil Corp" --proxy http://127.0.0.1:9050 -f custom_dorks.txt
SEE THE CONFIG FILE FOR DEFAULT QUERY LISTS AND TIMEOUT SETTINGS.
EOF
} 
