kubec() {
  local KUBE_DIR="${HOME}/.kube"
  local CONFIG_SUFFIX=".config"
  local chosen config_path

  # Require fzf
  if ! command -v fzf >/dev/null 2>&1; then
    print -u2 "fzf not found. Install fzf first."
    return 1
  fi

  # If a name is provided, use it directly
  if [[ $# -eq 1 ]]; then
    chosen="$1"
    config_path="${KUBE_DIR}/${chosen}${CONFIG_SUFFIX}"
    if [[ -f "$config_path" ]]; then
      export KUBECONFIG="$config_path"
      print "Switched to kubeconfig: ${chosen}"
      print "KUBECONFIG=${KUBECONFIG}"
      return 0
    else
      print -u2 "No such kubeconfig: $chosen"
      return 1
    fi
  fi

  # Gather kubeconfig names (strip .config)
  local -a names
  names=()
  local f base
  for f in "${KUBE_DIR}"/*.config; do
    [[ -e "$f" ]] || continue
    base="${f##*/}"
    names+="${base%${CONFIG_SUFFIX}}"
  done

  if (( ${#names[@]} == 0 )); then
    print -u2 "No *.config files found in ${KUBE_DIR}"
    return 1
  fi

  # Interactive select via fzf
  chosen="$(printf "%s\n" "${names[@]}" | fzf --prompt="Select kubeconfig> ")"

  # ESC/no selection → do nothing
  if [[ -z "$chosen" ]]; then
    print "No kubeconfig selected. Aborting."
    return 0
  fi

  config_path="${KUBE_DIR}/${chosen}${CONFIG_SUFFIX}"
  export KUBECONFIG="$config_path"
  print "Switched to kubeconfig: ${chosen}"
  print "KUBECONFIG=${KUBECONFIG}"
}
