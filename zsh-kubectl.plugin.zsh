#!/usr/bin/env zsh

COMPLETIONS_FILE_NAME="_kubectl"
COMPLETIONS_FOLDER="${ZAP_PLUGIN_DIR}/zsh-kubectl/completions"
COMPLETIONS_FILE_PATH="${COMPLETIONS_FOLDER}/${COMPLETIONS_FILE_NAME}"

if (( ! $+commands[kubectl] )); then
  return
fi

function make_completions()
{
  kubectl completion zsh 2>/dev/null
}

function make_completions_file()
{
  if [[ "$#" == "1" ]]; then
    local completion_file_path="${1}"
    make_completions > "${completion_file_path}" || 
    {
      exit 102
    }
  else
    exit 103
  fi
}

function calculate_sum()
{
  if [[ "$#" == "1" ]]; then
    echo "${1}" | md5sum | cut -d ' ' -f1
  else
    exit 104
  fi
}

# Main function
alias k=kubectl

if [[ ! -d "${COMPLETIONS_FOLDER}" ]]; then
  mkdir -p "${COMPLETIONS_FOLDER}" || 
  {
    exit 100
  }
fi

if [[ ! -f "${COMPLETIONS_FILE_PATH}" ]]; then
  make_completions_file "${COMPLETIONS_FILE_PATH}"
else
  if [[ "$(calculate_sum "$(make_completions)")" != "$(calculate_sum "$(cat "${COMPLETIONS_FILE_PATH}")")" ]]; then
    make_completions_file "${COMPLETIONS_FILE_PATH}"
  fi
fi

# Add completions to the FPATH
typeset -TUx FPATH fpath
fpath=("${COMPLETIONS_FOLDER}" $fpath)

# Delete functions after use
unfunction make_completions
unfunction make_completions_file
unfunction calculate_sum

# Error codes
# 101 - cant create completions folder
# 102 - cant create completions file
# 103 - wrong number of paramaters pass to function make_completions_file
# 104 - wrong number of paramaters pass to function calculate_sum