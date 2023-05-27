#!/usr/bin/env zsh

if (( ! $+commands[kubectl] )); then
  return
fi

function kubectl_completion()
{
  kubectl completion zsh 2>/dev/null
}

function kubectl_prepare_completion()
{
  local completion_file_path="${1}"
  kubectl_completion > "${completion_file_path}"
}

function kubectl_completion_sum()
{
  kubectl_completion | md5sum | cut -d ' ' -f1
}

function kubectl_completion_file_sum()
{
  local completion_file_path="${1}"
  md5sum "${completion_file_path}" | cut -d ' ' -f1
}

# This command is used a LOT in daily life
alias k=kubectl

local completions_file_name="_kubectl"
local completions_dir="${ZAP_PLUGIN_DIR}/zsh-kubectl/completions"
local completions_file_path="${completions_dir}/${completions_file_name}"

if [[ ! -f "${completions_file_path}" ]]; then
  kubectl_prepare_completion "${completions_file_path}"
else
  if [[ "$(kubectl_completion_sum)" != "$(kubectl_completion_file_sum "${completions_file_path}")" ]]; then
    kubectl_prepare_completion "${completions_file_path}"
  fi
fi

# Add completions to the FPATH
typeset -TUx FPATH fpath
fpath=("${completions_dir}" $fpath)

# Clear functions after use
unfunction kubectl_completion
unfunction kubectl_prepare_completion
unfunction kubectl_completion_sum
unfunction kubectl_completion_file_sum
