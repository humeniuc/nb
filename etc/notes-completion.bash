_notes_subcommands() {
  _cache_completions() {
    local _cache_path="${1:-}"

    local _commands
    _commands=($(notes commands))

    local _notebooks
    _notebooks=($(notes notebooks --names --no-color --unarchived))

    local _completions=()
    _completions=(${_commands[@]})

    local _commands_cached=
    local _notebooks_cached=

    if [[ -e "${_cache_path}" ]]
    then
      local _counter=0

      while IFS= read -r __line
      do
        _counter=$((_counter+1))

        if [[ "${_counter}" == 1 ]]
        then
          _commands_cached="${__line}"
        elif [[ "${_counter}" == 2 ]]
        then
          _notebooks_cached="${__line}"
        else
          break
        fi
      done < "${_cache_path}"
    fi

    if [[ "${_commands_cached}"  != "${_commands[*]:-}"   ]] ||
       [[ "${_notebooks_cached}" != "${_notebooks[*]:-}"  ]]
    then
      # Construct <notebook>:<subcommand> completions.
      for __notebook in "${_notebooks[@]}"
      do
        for __command in "${_commands[@]}"
        do
          if [[ -n "${__notebook:-}" ]] && [[ -n "${__command}" ]]
          then
            _completions+=("${__notebook}:${__command}")
          fi
        done
      done

      printf "" > "${_cache_path}"
      printf "%s\\n" "${_commands[*]}"    >> "${_cache_path}"
      printf "%s\\n" "${_notebooks[*]}"   >> "${_cache_path}"
      printf "%s\\n" "${_completions[@]}" >> "${_cache_path}"
    fi
  }

  local _cache_path="${HOME}/.notes-completion-cache-bash"
  local _completions_cached=()

  if [[ ! -e "${_cache_path}" ]]
  then
    _cache_completions "${_cache_path}"
  fi

  if [[ -e "${_cache_path}" ]]
  then
    local _counter=0

    while IFS= read -r __line
    do
      _counter=$((_counter+1))

      if [[ "${_counter}" -gt 2 ]]
      then
        _completions_cached+=("${__line}")
      fi
    done < "${_cache_path}"

    (_cache_completions "${_cache_path}" &)
  fi

  local _current="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=()

  COMPREPLY=($(compgen -W "${_completions_cached[*]}" -- ${_current}))
}

complete -F _notes_subcommands notes
