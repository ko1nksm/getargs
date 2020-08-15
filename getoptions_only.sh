# shellcheck shell=sh disable=SC2016
getoptions() {
  URL='https://github.com/ko1nksm/getoptions'
  LICENSE='Creative Commons Zero v1.0 Universal (CC0 Public Domain)'
  _error='' _on=1 _off='' _export='' _plus='' _mode='' _alt='' restargs=''
  _optargs='' _no='' _equal=1 indent='' IFS=' '

  for i in 0 1 2 3 4 5; do
    eval "_$i() { echo \"$indent\$*\"; }"
    indent="$indent  "
  done

  quote() {
    q="$2'" r=''
    while [ "$q" ]; do r="${r}${q%%\'*}'\''" && q=${q#*\'}; done
    q="'${r%????}'" && q=${q#\'\'} && q=${q%\'\'}
    eval "$1=\${q:-\"''\"}"
  }

  code() {
    [ ! "${1#:}" = "$1" ] && c=4 || c=3
    eval "[ ! \${$c:+x} ] || $2 \"\$$c\""
  }

  args() {
    on=$_on off=$_off export=$_export init='@empty' _optarg=${1#+}
    while [ $# -gt 2 ] && [ ! "$3" = '--' ] && shift; do
      case $2 in
        --no-* | --\{no-\}*) _no=1 ;;
        -?) [ "$_optarg" ] || _optargs="${_optargs}${2#-}" ;;
        +*) _plus=1 ;;
        [!-+]*) eval "${2%%:*}=\${2#*:}"
      esac
    done
  }

  defvar() {
    case $init in
      @empty) code "$1" _0 "${export:+export }$1=''" ;;
      @unset) code "$1" _0 "unset $1 ||:" "unset OPTARG ||:; ${1#:}" ;;
      *)  case $init in (@*) eval "init=\"=\${${init#@}}\""; esac
          case $init in ([!=]*) _0 "$init"; return 0; esac
          quote init "${init#=}"
          code "$1" _0 "${export:+export }$1=$init" "OPTARG=$init; ${1#:}"
    esac
  }

  setup() {
    restargs=$1 && shift
    for i; do [ "$i" = '--' ] && break; eval "_${i%%:*}=\${i#*:}"; done
  }
  flag() { args : "$@"; defvar "$@"; }
  param() { args + "$@"; defvar "$@"; }
  option() { args + "$@"; defvar "$@"; }
  disp() { args : "$@"; }
  msg() { args : _ "$@"; }

  _0 '# Option parser generated by getoptions'
  _0 "# URL: $URL"
  _0 "# LICENSE: $LICENSE"
  "$@"
  _0 "${restargs:?}=''"

  args() {
    sw='' on="$_on" off="$_off" validate='' counter='' default=''
    while [ $# -gt 1 ] && [ ! "$2" = '--' ] && shift; do
      case $1 in
        --\{no-\}* ) sw="${sw}${sw:+ | }--${1#--?no-?} | --no-${1#--?no-?}" ;;
        [-+]? | --*) sw="${sw}${sw:+ | }$1" ;;
        *) eval "${1%%:*}=\"\${1#*:}\""
      esac
    done
  }

  setup() { :; }
  flag() {
    args "$@"
    [ "$counter" ] && on=1 off=-1
    quote on "$on"
    quote off "$off"
    _3 "$sw)"
    _4 '[ "${OPTARG:-}" ] && set -- "$1" noarg && break'
    _4 "eval '[ \${OPTARG+x} ] &&:' && OPTARG=$on || OPTARG=$off"
    [ "$validate" ] && _4 "{ $validate; } || return \$?"
    [ "$counter" ] && code="\$((\${$1:-0} + \$OPTARG))" || code='$OPTARG'
    code "$1" _4 "$1=$code" "${1#:}"
    _4 ';;'
  }
  param() {
    args "$@"
    _3 "$sw)"
    _4 '[ $# -le 1 ] && set -- "$1" required && break'
    _4 'OPTARG=$2'
    [ "$validate" ] && _4 "{ $validate; } || return \$?"
    code "$1" _4 "$1=\$OPTARG" "${1#:}"
    _4 'shift ;;'
  }
  option() {
    args "$@"
    quote default "$default"
    _3 "$sw)"
    _4 'if [ ! "$OPTARG" ]; then'
    _5 "OPTARG=$default"
    _5 "eval 'shift; set -- \"'\"\$1\"'\" \"\$OPTARG\"' \${2+'\"\$@\"'}"
    _4 "fi"
    _4 'OPTARG=$2'
    [ "$validate" ] && _4 "{ $validate; } || return \$?"
    code "$1" _4 "$1=\$OPTARG" "${1#:}"
    _4 'shift ;;'
  }
  disp() {
    args "$@"
    _3 "$sw)"
    code "$1" _4 "echo \"\${$1}\"" "${1#:}"
    _4 'exit 0 ;;'
  }

  wa() { _4 "eval '${1% *}' \${1+'\"\$@\"'}"; }

  _0 "$2() {"
  _1 'OPTIND=$(($#+1))'
  _1 'while [ $# -gt 0 ] && OPTARG=; do'
  [ "$_alt" ] && _2 'case $1 in (-[!-]?*) set -- "-$@"; esac'
  _2 'case $1 in'
  if [ "$_equal" ]; then
    _3 '--?*=*) OPTARG=$1; shift'
    wa 'set -- "${OPTARG%%\=*}" "${OPTARG#*\=}" "$@"'
    _4 ';;'
  fi
  [ "$_no" ] && _3 '--no-*) unset OPTARG ;;'
  if [ ! "$_alt" ]; then
    if [ "$_optargs" ]; then
      _3 "-[$_optargs]?*) OPTARG=\$1; shift"
      wa 'set -- "${OPTARG%"${OPTARG#??}"}" "${OPTARG#??}" "$@"'
      _4 ';;'
    fi
    _3 '-[!-]?*) OPTARG=$1; shift'
    wa 'set -- "${OPTARG%"${OPTARG#??}"}" "-${OPTARG#??}" "$@"'
    _4 'OPTARG= ;;'
  fi
  if [ "$_plus" ]; then
    _3 '+??*) OPTARG=$1; shift'
    wa 'set -- "${OPTARG%"${OPTARG#??}"}" "+${OPTARG#??}" "$@"'
    _4 'unset OPTARG ;;'
    _3 '+*) unset OPTARG ;;'
  fi
  _2 'esac'
  _2 'case $1 in'
  "$@"
  _3 '--)'
  _4 'while [ $# -gt 1 ] && shift; do'
  _5 "$restargs=\"\${$restargs}" '\"\${$(($OPTIND-$#))}\""'
  _4 'done ;;'
  _3 "[-${_plus:++}]?*)" 'set -- "$1" unknown && break ;;'
  if [ "$_mode" = '+' ]; then
    _3 '*)'
    _4 'while [ $# -gt 0 ]; do'
    _5 "$restargs=\"\${$restargs}" '\"\${$(($OPTIND-$#))}\""'
    _5 'shift'
    _4 'done'
    _4 'break'
  else
    _3 "*) $restargs=\"\${$restargs}" '\"\${$(($OPTIND-$#))}\""'
  fi
  _2 'esac'
  _2 'shift'
  _1 'done'
  _1 '[ $# -eq 0 ] && return 0'
  [ "$_error" ] && _1 "$_error" '"$@" && exit 1'
  _1 'case $2 in'
  _2 "unknown) echo \"unrecognized option '\$1'\" ;;"
  _2 "noarg) echo \"option '\$1' doesn't allow an argument\" ;;"
  _2 "required) echo \"option '\$1' requires an argument\" ;;"
  _1 'esac >&2'
  _1 'exit 1'
  _0 '}'
  _0 '# End of option parser'
}
