##!/bin/bash
# Copyright (c) 2009-2021 Volodymyr M. Lisivka <vlisivka@gmail.com>, All Rights Reserved
# License: LGPL2+

#>> ## NAME
#>>
#>>> `log` - various functions related to logging.

#>
#> ## VARIABLES

#export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}}: '.

#> * `__log__APP` - name of main file without path.
__log__APP="${IMPORT__BIN_FILE##*/}" # Strip everything before last "/"

#> * `__log__DEBUG` - set to yes to enable printing of debug messages and stacktraces.
#> * `__log__STACKTRACE` - set to yes to enable printing of stacktraces.

#>>
#>> ## FUNCTIONS

#>>
#>> * `stacktrace [INDEX]` - display functions and source line numbers starting
#>> from given index in stack trace, when debugging or back tracking is enabled.
log::stacktrace() {
  [ "${__log__DEBUG:-}" != "yes" -a "${__log__STACKTRACE:-}" != "yes" ] || {
    local BEGIN="${1:-1}" # Display line numbers starting from given index, e.g. to skip "log::stacktrace" and "error" functions.
    local I
    for(( I=BEGIN; I<${#FUNCNAME[@]}; I++ ))
    do
      echo $'\t\t'"at ${FUNCNAME[$I]}(${BASH_SOURCE[$I]}:${BASH_LINENO[$I-1]})" >&2
    done
    echo
  }
}

#>>
#>> * `error MESAGE...` - print error message and stacktrace (if enabled).
error() {
  if [ -t 2 ]
  then
    # STDERR is tty
    local __log_ERROR_BEGIN=$'\033[91m'
    local __log_ERROR_END=$'\033[39m'
    echo "[$__log__APP] [$$] ${__log_ERROR_BEGIN}ERROR${__log_ERROR_END}: ${*:-}" >&2
  else
    echo "[$__log__APP] [$$] ERROR: ${*:-}" >&2
  fi
  log::stacktrace 2
}

#>>
#>> * `warn MESAGE...` - print warning message and stacktrace (if enabled).
warn() {
  if [ -t 2 ]
  then
    # STDERR is tty
    local __log_WARN_BEGIN=$'\033[96m'
    local __log_WARN_END=$'\033[39m'
    echo "[$__log__APP] [$$] ${__log_WARN_BEGIN}WARN${__log_WARN_END}: ${*:-}" >&2
  else
    echo "[$__log__APP] [$$] WARN: ${*:-}" >&2
  fi
  log::stacktrace 2
}

#>>
#>> * `info MESAGE...` - print info message.
info() {
  if [ -t 1 ]
  then
    # STDOUT is tty
    local __log_INFO_BEGIN=$'\033[92m'
    local __log_INFO_END=$'\033[39m'
    echo "[$__log__APP] [$$] ${__log_INFO_BEGIN}INFO${__log_INFO_END}: ${*:-}"
  else
    echo "[$__log__APP] [$$] INFO: ${*:-}"
  fi
}

#>>
#>> * `debug MESAGE...` - print debug message, when debugging is enabled only.
debug() {
 [ "${__log__DEBUG:-}" != yes ] || echo "[$__log__APP] [$$] DEBUG: ${*:-}"
}

#>>
#>> * `log::fatal LEVEL MESSAGE...` - print a fatal-like LEVEL: MESSAGE to STDERR.
log::fatal() {
  local LEVEL="$1" ; shift
  if [ -t 2 ]
  then
    # STDERR is tty
    local __log_ERROR_BEGIN=$'\033[95m'
    local __log_ERROR_END=$'\033[39m'
    echo "[$__log__APP] [$$] ${__log_ERROR_BEGIN}$LEVEL${__log_ERROR_END}: ${*:-}" >&2
  else
    echo "[$__log__APP] [$$] $LEVEL: ${*:-}" >&2
  fi
}

#>>
#>> * `log::error LEVEL MESSAGE...` - print error-like LEVEL: MESSAGE to STDERR.
log::error() {
  local LEVEL="$1" ; shift
  if [ -t 2 ]
  then
    # STDERR is tty
    local __log_ERROR_BEGIN=$'\033[91m'
    local __log_ERROR_END=$'\033[39m'
    echo "[$__log__APP] [$$] ${__log_ERROR_BEGIN}$LEVEL${__log_ERROR_END}: ${*:-}" >&2
  else
    echo "[$__log__APP] [$$] $LEVEL: ${*:-}" >&2
  fi
}

#>>
#>> * `log::warn LEVEL MESSAGE...` - print warning-like LEVEL: MESSAGE to STDERR.
log::warn() {
  local LEVEL="${1:-WARN}" ; shift
  if [ -t 2 ]
  then
  # STDERR is tty
    local __log_WARN_BEGIN=$'\033[96m'
    local __log_WARN_END=$'\033[39m'
    echo "[$__log__APP] [$$] ${__log_WARN_BEGIN}$LEVEL${__log_WARN_END}: ${*:-}" >&2
  else
    echo "[$__log__APP] [$$] $LEVEL: ${*:-}" >&2
  fi
}

#>>
#>> * `log::info LEVEL MESSAGE...` - print info-like LEVEL: MESSAGE to STDOUT.
log::info() {
  local LEVEL="${1:-INFO}" ; shift
  if [ -t 1 ]
  then
    # STDOUT is tty
    local __log_INFO_BEGIN=$'\033[92m'
    local __log_INFO_END=$'\033[39m'
    echo "[$__log__APP] [$$] ${__log_INFO_BEGIN}${LEVEL}${__log_INFO_END}: ${*:-}"
  else
    echo "[$__log__APP] [$$] ${LEVEL}: ${*:-}"
  fi
}

#>>
#>> * `panic MESAGE...` - print error message and stacktrace, then exit with error code 1.
panic() {
  log::fatal "PANIC"  "${*:-}"
  log::enable_stacktrace
  log::stacktrace 2
  exit 1
}

#>>
#>> * `unimplemented MESAGE...` - print error message and stacktrace, then exit with error code 42.
unimplemented() {
  log::fatal "UNIMPLEMENTED" "${*:-}"
  log::enable_stacktrace
  log::stacktrace 2
  exit 42
}


#>>
#>> * `todo MESAGE...` - print todo message and stacktrace.
todo() {
  log::warn "TODO" "${*:-}"
  local __log__STACKTRACE="yes"
  log::stacktrace 2
}

#>>
#>> * `dbg VARIABLE...` - print name of variable and it content to stderr
dbg() {
  local __dbg_OUT=$( declare -p "$@" )

  if [ -t 2 ]
  then
    # STDERR is tty
    local __log_DBG_BEGIN=$'\033[96m'
    local __log_DBG_END=$'\033[39m'
    echo "[$__log__APP] [$$] ${__log_DBG_BEGIN}DBG${__log_DBG_END}: ${__dbg_OUT//declare -? /}" >&2
  else
    echo "[$__log__APP] [$$] DBG: ${__dbg_OUT//declare -? /}" >&2
  fi
}

#>>
#>> * `log::enable_debug_mode` - enable debug messages and stack traces.
log::enable_debug_mode() {
  __log__DEBUG="yes"
}

#>>
#>> * `log::disable_debug_mode` - disable debug messages and stack traces.
log::disable_debug_mode() {
  __log__DEBUG="no"
}

#>>
#>> * `log::enable_stacktrace` - enable stack traces.
log::enable_stacktrace() {
  __log__STACKTRACE="yes"
}

#>>
#>> * `log::disable_stacktrace` - disable stack traces.
log::disable_stacktrace() {
  __log__STACKTRACE="no"
}

#>>
#>> ## NOTES
#>>
#>> - If STDOUT is connected to tty, then
#>>   * info and info-like messages will be printed with message level higlighted in green,
#>>   * warn and warn-like messages will be printed with message level higlighted in yellow,
#>>   * error and error-like messages will be printed with message level higlighted in red.
