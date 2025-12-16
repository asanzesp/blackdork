#!/bin/bash

# Load source modules
load_source_module() {
  local module_path="${SCRIPT_DIR}/modules/$1"
      
  if [ ! -f "$module_path" ]; then
  
    if [ "$1" != "logger.sh" ]; then
      log_error "Module not found: $module_path"
    else
      echo "Module not found: $module_path"
    fi
   
    exit 1           
  fi
    
  source "$module_path"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/config.sh"
load_source_module "logger.sh"
load_source_module "utils.sh"

declare -i NUM_OF_RESULTS=0
declare -a NORMAL_OUTPUT
declare -a XML_OUTPUT
declare -a queries

main() {

  # Main logic
  if ! check_dependencies REQUIRED_COMMANDS; then
    log_error "Missing dependencies"
    exit 1
  fi
  
  full_command="$0 $@"
  
  # While loop that runs as long as parameters exist
  while [ "$1" != "" ]; do
    case "$1" in
      "-d" | "--domain")
        shift
        domain="$1"
        ;;
      "-n" | "--name")
        shift
        name="$1"
        ;;
      "-c" | "--company")
        shift
        company="$1"
        ;;
      "-e" | "--email")
        shift
        email="$1"
        ;;
      "-u" | "--username")
        shift
        username="$1"
        ;;
      "-f" | "--file")
        shift
        queries_list_path="$1"
        ;;
      "--proxy")
        shift
        proxy_url="$1"
        ;;
      "-oN" | "--outputNormal")
        shift
        normal_output_path="$1"
        ;;
      "-oX" | "--outputXML")
        shift
        xml_output_path="$1"
        ;;
      "-oA" | "--outputAll")
        shift
        all_output_path="$1"
        ;;
      "-v" | "--verbose")
        export VERBOSE=true
        ;;
      "-h" | "--help")
        get_help
        exit 0
        ;;
      *)
        echo "Unrecognized parameter: $1"
        echo "QUITTING!"
        exit 1
        ;;
    esac
    # Shift at the end of the loop to move to the next parameter
    shift
  done
  
  if [ -z "$domain" ] && [ -z "$name" ] && [ -z "$company" ] && [ -z "$email" ] && [ -z "$username" ]; then
    log_error "No search target was specified. Please use -d/--domain, -n/--name, -c/--company, -e/--email or -u/--username"
    echo "QUITTING!"
    exit 1
  fi
      
  NORMAL_OUTPUT+=("# $PROJECT_NAME $VERSION Google Dorking initiated $(get_current_datetime) as: $full_command")
  
  XML_OUTPUT+=("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
  
  project_name=$PROJECT_NAME

  project_name_lowercase=${project_name,,}
    
  XML_OUTPUT+=("<!DOCTYPE "$project_name_lowercase"run>")

  XML_OUTPUT+=("<"$project_name_lowercase"run args=\"$full_command\" start=\"$start_timestamp\" startstr=\"$(get_current_datetime_with_time_zone)\" version=\"1.0\" xmloutputversion=\"1.0\">")
  
  if [ -n "$domain" ]; then
    
    if is_valid_domain "$domain"; then
    
      echo "$PROJECT_NAME domain Google Dorking report for $domain"
      
      NORMAL_OUTPUT+=("$PROJECT_NAME domain Google Dorking report for $domain")
            
      XML_OUTPUT+=("<google_dorking type=\"domain\" target=\"$domain\"/>")
      
      if [ "$VERBOSE" = true ]; then
        echo "Google Dorking $domain"
      fi
            
      if [ -n "$queries_list_path" ]; then
        get_queries_list "$queries_list_path"
      else
        get_queries_list "$DOMAIN_QUERIES_LIST"
      fi
      
      total=${#queries[@]}
      
      last_element_index=$((total - 1))

      for ((i=0; i<total; i++)); do
      
        # Ignore empty lines or lines starting with #
        if [[ -z "${queries[i]}" || "${queries[i]}" =~ ^# ]]; then
          continue
        fi

        # Replace TARGET with $domain
        query="${queries[i]//TARGET/$domain}"
        
        if [ "$VERBOSE" = true ]; then          
          echo -e $'\n'"Google Dorking initiated for: $domain (Query -> $query)"
        fi 
        
        get_URLs "$query" "$proxy_url"
        
        # Wait a few random seconds when it's not the last query
        if [ $i -ne $last_element_index ]; then
          # Wait 5-10 seconds
          sleep $((RANDOM % 5 + 5))
        fi
     
      done
      
    else
      log_error "Not a valid domain"
      echo "QUITTING!"
      exit 1
    fi
    
  elif [ -n "$name" ]; then
    
    if is_valid_name "$name"; then
      
      echo "$PROJECT_NAME name Google Dorking report for $name"
      
      NORMAL_OUTPUT+=("$PROJECT_NAME name Google Dorking report for $name")
            
      XML_OUTPUT+=("<google_dorking type=\"name\" target=\"$name\"/>")
      
      if [ "$VERBOSE" = true ]; then
        echo "Google Dorking $name"
      fi
      
      if [ -n "$queries_list_path" ]; then
        get_queries_list "$queries_list_path"
      else
        get_queries_list "$NAME_QUERIES_LIST"
      fi
  
      total=${#queries[@]}
      
      # Calculate the index of the last element
      last_element_index=$((total - 1))

      for ((i=0; i<total; i++)); do
      
        # Ignore empty lines or lines starting with #
        if [[ -z "${queries[i]}" || "${queries[i]}" =~ ^# ]]; then
          continue
        fi

        # Replace TARGET with $name
        query="${queries[i]//TARGET/$name}"
        
        if [ "$VERBOSE" = true ]; then          
          echo -e $'\n'"Google Dorking initiated for: $name (Query -> $query)"
        fi 
        
        get_URLs "$query" "$proxy_url"
        
        # Wait a few random seconds when it's not the last query
        if [ $i -ne $last_element_index ]; then
          # Wait 5-10 seconds
          sleep $((RANDOM % 5 + 5))
        fi
     
      done
      
    else
      log_error "Not a valid name"
      echo "QUITTING!"
      exit 1
    fi
    
  elif [ -n "$company" ]; then
    
    if is_valid_company_name "$company"; then
      
      echo "$PROJECT_NAME company name Google Dorking report for $company"
      
      NORMAL_OUTPUT+=("$PROJECT_NAME company name Google Dorking report for $company")
            
      XML_OUTPUT+=("<google_dorking type=\"company\" target=\"$company\"/>")
      
      if [ "$VERBOSE" = true ]; then
        echo "Google Dorking $company"
      fi
      
      if [ -n "$queries_list_path" ]; then
        get_queries_list "$queries_list_path"
      else
        get_queries_list "$COMPANY_QUERIES_LIST"
      fi
  
      total=${#queries[@]}
      
      # Calculate the index of the last element
      last_element_index=$((total - 1))

      for ((i=0; i<total; i++)); do

        # Ignore empty lines or lines starting with #
        if [[ -z "${queries[i]}" || "${queries[i]}" =~ ^# ]]; then
          continue
        fi

        # Replace TARGET with $company
        query="${queries[i]//TARGET/$company}"
        
        if [ "$VERBOSE" = true ]; then          
          echo -e $'\n'"Google Dorking initiated for: $company (Query -> $query)"
        fi 
        
        get_URLs "$query" "$proxy_url"
        
        # Wait a few random seconds when it's not the last query
        if [ $i -ne $last_element_index ]; then
          # Wait 5-10 seconds
          sleep $((RANDOM % 5 + 5))
        fi
     
      done
      
    else
      log_error "Not a valid company name"
      echo "QUITTING!"
      exit 1
    fi
    
  elif [ -n "$email" ]; then
    
    if is_valid_email "$email"; then
      
      echo "$PROJECT_NAME email Google Dorking report for $email"
      
      NORMAL_OUTPUT+=("$PROJECT_NAME email Google Dorking report for $email")
            
      XML_OUTPUT+=("<google_dorking type=\"email\" target=\"$email\"/>")
      
      if [ "$VERBOSE" = true ]; then
        echo "Google Dorking $email"
      fi
      
      if [ -n "$queries_list_path" ]; then
        get_queries_list "$queries_list_path"
      else
        get_queries_list "$EMAIL_QUERIES_LIST"
      fi
  
      total=${#queries[@]}
      
      last_element_index=$((total - 1))

      for ((i=0; i<total; i++)); do

        # Ignore empty lines or lines starting with #
        if [[ -z "${queries[i]}" || "${queries[i]}" =~ ^# ]]; then
          continue
        fi

        # Replace TARGET with $email
        query="${queries[i]//TARGET/$email}"
        
        if [ "$VERBOSE" = true ]; then
          echo -e $'\n'"Google Dorking initiated for: $email (Query -> $query)"
        fi 
        
        get_URLs "$query" "$proxy_url"
        
        # Wait a few random seconds when it's not the last query
        if [ $i -ne $last_element_index ]; then
          # Wait 5-10 seconds
          sleep $((RANDOM % 5 + 5))
        fi
     
      done
      
    else
      log_error "Not a valid email"
      echo "QUITTING!"
      exit 1
    fi
    
  elif [ -n "$username" ]; then
    
    if is_valid_username "$username"; then
      
      echo "$PROJECT_NAME username Google Dorking report for $username"
      
      NORMAL_OUTPUT+=("$PROJECT_NAME username Google Dorking report for $username")
            
      XML_OUTPUT+=("<google_dorking type=\"username\" target=\"$username\"/>")
      
      if [ "$VERBOSE" = true ]; then
        echo "Google Dorking $username"
      fi
      
      if [ -n "$queries_list_path" ]; then
        get_queries_list "$queries_list_path"
      else
        get_queries_list "$USERNAME_QUERIES_LIST"
      fi
  
      total=${#queries[@]}
      
      # Calculate the index of the last element
      last_element_index=$((total - 1))

      for ((i=0; i<total; i++)); do

        # Ignore empty lines or lines starting with #
        if [[ -z "${queries[i]}" || "${queries[i]}" =~ ^# ]]; then
          continue
        fi

        # Replace TARGET with $username
        query="${queries[i]//TARGET/$username}"
        
        if [ "$VERBOSE" = true ]; then          
          echo -e $'\n'"Google Dorking initiated for: $username (Query -> $query)"
        fi 
        
        get_URLs "$query" "$proxy_url"
        
        # Wait a few random seconds when it's not the last query
        if [ $i -ne $last_element_index ]; then
          # Wait 5-10 seconds
          sleep $((RANDOM % 5 + 5))
        fi
     
      done
      
    else
      log_error "Not a valid username"
      echo "QUITTING!"
      exit 1
    fi
    
  fi

  local elapsed_seconds=$(get_elapsed_seconds "$start_timestamp")

  echo -e $'\n'"$PROJECT_NAME done: Google Dorking completed in $elapsed_seconds seconds -- Found $NUM_OF_RESULTS results"
    
  NORMAL_OUTPUT+=("# $PROJECT_NAME $VERSION done at $(get_current_datetime) -- Google Dorking completed in $elapsed_seconds seconds -- Found $NUM_OF_RESULTS results")

  XML_OUTPUT+=("<runstats>")
  XML_OUTPUT+=("<finished time=\"$(get_current_timestamp)\" timestr=\"$(get_current_datetime)\" summary=\"$PROJECT_NAME $VERSION done at $(get_current_datetime) scanned in $elapsed_seconds seconds\" elapsed=\"$elapsed_seconds\" total_results=\"$NUM_OF_RESULTS\" exit=\"success\"/>")
  XML_OUTPUT+=("</runstats>")  
  XML_OUTPUT+=("</"$(get_project_name_lowercase)"run>")

  if [ -n "$all_output_path" ]; then
    create_file_output "normal" ""$all_output_path".blackdork"
    create_file_output "xml" ""$all_output_path".xml"
  else

    if [ -n "$normal_output_path" ]; then
      create_file_output "normal" "$normal_output_path"
    fi
    
    if [ -n "$xml_output_path" ]; then
      create_file_output "xml" "$xml_output_path"
    fi
    
  fi
}

# Execute only if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

  start_timestamp=$(get_current_timestamp)

  echo "Starting $PROJECT_NAME $VERSION at $(get_current_datetime_with_time_zone)"
  
  main "$@"
fi
