#===============================================================================
# NAME
#
# SYNOPSIS
#       . log4sh.sh [-l level] [-t 0|1] [-T 0|1] [-D 0|1] [-c 0|1] [-f file] [-d path to GNU date] [-qhup]
#
# DESCRIPTION
#       A shell logging library, based on L<log4bats|https://github.com/goozbach/log4bats>.
#
# OPTIONS
#       -l level    - ALL(TRACE), DEBUG, INFO, WARN, ERROR, FATAL, NONE
#       -t [01]     - date/timestamp preceded a message
#       -T [01]     - date/timestamp only in a log file (enabled only global date/timestamp is enabled)
#       -D [01]     - write DEBUG information to logfile
#       -c [01]     - use color
#       -f file     - a log file
#       -d file     - a path to the GNU date
#       -p          - use Perl instead GNU date, it requires following modules: Time::HiRes and POSIX
#       -q          - be quiet
#       -u          - show full usage with additional information
#       -h          - show help
#
# BUGS
#       To prevent mixing of positional arguments source the file inside
#       a function, eg.
#
#       log4sh(){ . ./log4sh.sh || exit 1 }
#       log4sh
#
#       Without this log4sh.sh modifies positional parameters.
#       FIXED
#
# EXAMPLES
#       $ . log4sh.sh || exit 1
#       $ INFO lorem ipsum
#       2016-11-29-14:07:42 INFO - lorem ipsum
#
#       $ FATAL another fatal error
#       2016-11-29-14:08:20 FATAL - another fatal error
#
#       $ LOG4SH_DATE=0 # disable timestamp
#       FATAL - another fatal error
#
#       $ LOG4SH_LEVEL=ERROR # logging only error, fatal
#
#       $ LOG4SH_FILE='some_program.log'
#       $ INFO 'a message' # write also to log file with timestamp
#       INFO - a message
#       # or
#       $ . log4sh.sh -f log_file
#       INFO "log to file"
#       echo "write this also to log_file" | tee -a $LOG4SH_FILE
#
#       $ . log4sh.sh || exit 1
#       $ INFO lorem ipsum
#       2016-11-29-14:07:42 INFO - lorem ipsum
#       $ log4sh_init other_parameters
#
# AUTHOR
#       Piotr Rogoza <piotr.r.public@gmail.com
#
#===============================================================================

function _log4sh_usage {
    printf "Usage:\n\t. log4sh.sh [-l level] [-t 0|1] [-T 0|1] [-c 0|1] [-qhD] [-f file] [-d path to GNU date]\n\n"
}

function _log4sh_help {
    _log4sh_usage
    printf "\t-l level - a log level\n"
    printf "\t-t 0|1   - switch on/off data/timestamp\n"
    printf "\t-T 0|1   - switch on/off data/timestamp only in a log file\n"
    printf "\t-D       - switch on/off writing DEBUG to a log file\n"
    printf "\t-c 0|1   - switch on/off colors\n"
    printf "\t-f file  - path log file\n"
    printf "\n"
    printf "\t-d file  - path to GNU date\n"
    printf "\t-p       - use Perl replacment for GNU date, it's slower\n"
    printf "\n"
    printf "\t-q       - be quiet\n"
    printf "\t-u       - show full usage with additional information\n"
    printf "\t-h       - show help\n"
    printf "\n"
    printf "%s\n" "To process new parameters, you have to invoke log4sh_init function with new ones"
}

function _log4sh_show_usage {
    _log4sh_help
    printf '\n'
    printf '%s\n' "Each level includes the one below. (ie WARN will print WARN, ERROR, and FATAL messages)"
    printf '%s\n' " * ALL -- synonym for TRACE"
    printf '%s\n' " * TRACE"
    printf '%s\n' " * DEBUG"
    printf '%s\n' " * INFO"
    printf '%s\n' " * WARN"
    printf '%s\n' " * ERROR"
    printf '%s\n' " * FATAL"
    printf '%s\n' " * NONE -- no logging"
    printf '\n'
    printf '%s\n' "There are the normal logging message functions, each corresponds to a given log level:"
    printf '%s\n' " * log_fatal, FATAL"
    printf '%s\n' " * log_die, DIE - like log_fatal but it also exits with code 200"
    printf '%s\n' " * log_error, ERROR"
    printf '%s\n' " * log_warn, WARN"
    printf '%s\n' " * log_info, INFO"
    printf '%s\n' " * log_debug, DEBUG"
    printf '%s\n' " * log_trace, TRACE"
    printf '\n'
    printf '%s\n' "There are following control variables (with default options) which can be overwritten in a shell:"
    printf '%s\n' " * LOG4SH_DATE=1 - do print a timestamp?"
    printf '%s\n' " * LOG4SH_DATE_LOG=1 - do print a timestamp in a log file?"
    printf '%s\n' " * LOG4SH_DATE_FORMAT="+%FT%TZ" - a format of the timestamp, ISO8601 standard"
    printf '%s\n' " * LOG4SH_DATE_BIN="" - localization of the GNU date"
    printf '%s\n' " * LOG4SH_FORMAT="" - a format for the header of each message. It overwrites the default format: timestamp log-level"
    printf '%s\n' " * LOG4SH_COLOR=1 - do print with colors?"
    printf '%s\n' " * LOG4SH_QUIET=0 - do be quiet?"
    printf '%s\n' " * LOG4SH_LEVE=INFO - the priority of the log message, logging level. Same as for Log4Perl and Log4j"
    printf '%s\n' " * LOG4SH_FILE='' - a log file"
    printf '%s\n'
    printf '%s\n' "and variables for colors:"
    printf '%s\n' ' * LOG4SH_COLOR_BOLD="^[[1;37m"'
    printf '%s\n' ' * LOG4SH_COLOR_RED="^[[1;31m"'
    printf '%s\n' ' * LOG4SH_COLOR_WHITE="^[[0;37m"'
    printf '%s\n' ' * LOG4SH_COLOR_GREEN="^[[1;32m"'
    printf '%s\n' ' * LOG4SH_COLOR_YELLOW="^[[1;33m"'
    printf '%s\n' ' * LOG4SH_COLOR_BLUE="^[[1;34m"'
    printf '%s\n' ' * LOG4SH_COLOR_CYAN="^[[1;36m"'
    printf '%s\n' ' * LOG4SH_COLOR_OFF="^[[0m"'
    printf '%s\n'
    printf '%s\n' ' * LOG4SH_DEFAULT_COLOR="$LOG4SH_COLOR_OFF"'
    printf '%s\n' ' * LOG4SH_ERROR_COLOR="$LOG4SH_COLOR_RED"'
    printf '%s\n' ' * LOG4SH_FATAL_COLOR="$LOG4SH_COLOR_RED"'
    printf '%s\n' ' * LOG4SH_INFO_COLOR="$LOG4SH_COLOR_WHITE"'
    printf '%s\n' ' * LOG4SH_SUCCESS_COLOR="$LOG4SH_COLOR_GREEN"'
    printf '%s\n' ' * LOG4SH_WARN_COLOR="$LOG4SH_COLOR_YELLOW"'
    printf '%s\n' ' * LOG4SH_DEBUG_COLOR="$LOG4SH_COLOR_BLUE"'
    printf '%s\n' ' * LOG4SH_TRACE_COLOR="$LOG4SH_COLOR_CYAN"'
}

function log4sh_init {
    typeset program_options='c:d:f:l:t:T:Dhqpu'
    typeset options retval
    options=$(getopt $program_options $* 2>/dev/null)
    retval=$?
    if (( retval )); then
        _log4sh_usage
        return 1
    fi
    eval set -- "$options"
    while [[ "$1" != -- ]]; do
        case $1 in
            -c) LOG4SH_COLOR=$2; shift ;;
            -d) LOG4SH_DATE_BIN=$2; shift ;;
            -f) LOG4SH_FILE=$2; shift ;;
            -l) LOG4SH_LEVEL=$2; shift ;;
            -t) LOG4SH_DATE=$2; shift ;;
            -T) LOG4SH_DATE_LOG=$2; shift ;;
            -D) LOG4SH_DEBUG_LOG=1 ;;
            -h) _log4sh_help; return;;
            -u) _log4sh_show_usage; return;;
            -q) LOG4SH_QUIET=1 ;;
            -p) LOG4SH_DATE_BIN=perl ;;
            *) _log4sh_usage; return 1 ;;
        esac
        shift
    done
    shift # remove --
}

log4sh_init "$@"
if (( $? )); then
    return 1
fi

# some default values, can be overwritten in shell
: ${LOG4SH_DATE=1}                            # do print timestamp?
: ${LOG4SH_DATE_LOG=1}                        # print timestamp only in log file
: ${LOG4SH_DATE_FORMAT="+%FT%TZ"}             # format of timestamp, extended ISO8601
LOG4SH_DEFAULT_DATE_FORMAT="+%FT%TZ"
: ${LOG4SH_COLOR=1}                           # do use color?
: ${LOG4SH_QUIET=0}                           # be quiet
: ${LOG4SH_LEVEL=INFO}                        # default log level
: ${LOG4SH_FORMAT=''}                         # instead it is used timestamp and loglevel
LOG4SH_DEFAULT_FORMAT='${_log_date}${_LOG_LVL} - '
LOG4SH_DEFAULT_SHORT_FORMAT='${_LOG_LVL} - '
: ${LOG4SH_DATE_BIN=''}                       # path to GNU date
: ${LOG4SH_FILE=''}                           # a log file
: ${LOG4SH_DEBUG_LOG=0}                       # write DEBUG information to a log file

: ${LOG4SH_COLOR_BOLD="[1;37m"}
: ${LOG4SH_COLOR_RED="[1;31m"}
: ${LOG4SH_COLOR_WHITE="[0;37m"}
: ${LOG4SH_COLOR_GREEN="[1;32m"}
: ${LOG4SH_COLOR_YELLOW="[1;33m"}
: ${LOG4SH_COLOR_BLUE="[1;34m"}
: ${LOG4SH_COLOR_CYAN="[1;36m"}
: ${LOG4SH_COLOR_OFF="[0m"}

: ${LOG4SH_DEFAULT_COLOR="$LOG4SH_COLOR_OFF"}
: ${LOG4SH_ERROR_COLOR="$LOG4SH_COLOR_RED"}
: ${LOG4SH_FATAL_COLOR="$LOG4SH_COLOR_RED"}
: ${LOG4SH_INFO_COLOR="$LOG4SH_COLOR_WHITE"}
: ${LOG4SH_SUCCESS_COLOR="$LOG4SH_COLOR_GREEN"}
: ${LOG4SH_WARN_COLOR="$LOG4SH_COLOR_YELLOW"}
: ${LOG4SH_DEBUG_COLOR="$LOG4SH_COLOR_BLUE"}
: ${LOG4SH_TRACE_COLOR="$LOG4SH_COLOR_CYAN"}

: ${LOG4SH_COLOR_BEGIN=$LOG4SH_DEFAULT_COLOR}

if [[ -n "$LOG4SH_DATE_BIN" && $LOG4SH_DATE_BIN == 'perl' ]]; then
    _log4sh_date() {
       typeset script=$(cat <<'EOF'
use POSIX qw(strftime);
use Time::HiRes qw(time);
use English qw( -no_match_vars );

sub parseCommandLineOptions {
    my ( $option ) = @ARG;
    for my $index (0 .. $#ARGV) {
        if ($ARGV[$index] eq q{-u}) {
            $option->{utc} = 1;
        }
        elsif ($ARGV[$index] =~ /\+%/) {
            ( $option->{format} ) = $ARGV[$index] =~ m/\+(.*)/;
        }
        elsif ($ARGV[$index] =~ /%/ && $ARGV[$index] !~ /\+/) {
            print qq{date: invalid date $ARGV[$index]\n};
            exit 1;
        }
        elsif ( $ARGV[$index] =~ /^-d[^ ]+/ ) {
            ( $option->{date} ) = $ARGV[$index] =~ m/-d@?(.*)/;
        }
        elsif ( $ARGV[$index] =~ /^-d$/ ) {
            ( $option->{date} ) = $ARGV[$index+1] =~ m/@?(.*)/;
        }
    }
}
my $option = {
    format => q{%a %b %e %H:%M:%S %Z %Y},
};
parseCommandLineOptions($option);
my $time;
if ( $option->{date} ) {
    $time = $option->{date};
}
else {
    if ( $option->{utc} ) {
        $time = sprintf q{%.9f}, gmtime();
    }
    else {
        $time = sprintf q{%.9f}, time();
    }
}
my ( $nsec ) = $time =~ m/\.(.*)/;
my @time = localtime $time;
my $nsecFlag;
if ( $option->{format} =~ m/%N$/ ) {
    $option->{format} =~ s/%N//;
    $nsecFlag = 1;
}
my $formatedTime = strftime qq{$option->{format}}, @time;
if ( $nsecFlag ) {
    $formatedTime .= $nsec;
}
print $formatedTime, qq{\n};
EOF
        )
        perl -e "$script" -- "$@"
    }
# overwrite default date of AIX
elif [ -x /opt/freeware/bin/date ]; then
    _log4sh_date() {
        /opt/freeware/bin/date "$@"
    }
# GNU date
elif date --version >/dev/null 2>&1; then
    _log4sh_date() {
        date "$@"
    }
elif [[ -n "$LOG4SH_DATE_BIN" && -x $LOG4SH_DATE_BIN ]]; then
    _log4sh_date() {
        $LOG4SH_DATE_BIN "$@"
    }
else
    printf "FATAL - Missing GNU date. I cannot use AIX or other date.\n"
    return
fi

_log4sh_do_dispatch(){
    typeset message="$@"
    typeset _log_date
    if [ -n "$LOG4SH_DATE" ] && (( LOG4SH_DATE )); then
        _log_date=$(_log4sh_date -u ${LOG4SH_DATE_FORMAT:-$LOG4SH_DEFAULT_DATE_FORMAT} -d @${_LOG_STAMP:-$(_log4sh_date +%s.%N)})
        _log_date="$_log_date "
    else
        _log_date=
    fi
    if [[ -n "$LOG4SH_FORMAT" && ! $LOG4SH_FORMAT = @(* ) ]]; then
        LOG4SH_FORMAT="$LOG4SH_FORMAT "
    fi
    # Write DEBUG message to log file but only when:
    if [[ "$_LOG_LVL" = 'DEBUG' && $LOG4SH_LEVEL = $(INFO|WARN|ERROR|FATAL) && -n "$LOG4SH_FILE" ]] && (( LOG4SH_DEBUG_LOG )); then
        printf "%s\n" "${LOG4SH_FORMAT:-$(eval printf '%b' \"${LOG4SH_DEFAULT_FORMAT}\")}${message}" >> $LOG4SH_FILE
    else
        # Without logfile
        if [ -z "$LOG4SH_FILE" ]; then
            if (( ! LOG4SH_QUIET )); then
                printf "%b\n" "${LOG4SH_COLOR_BEGIN}${LOG4SH_FORMAT:-$(eval printf '%s' \"${LOG4SH_DEFAULT_FORMAT}\")}${message}${LOG4SH_COLOR_OFF}"
            fi
        # With logfile
        elif [ -n "$LOG4SH_FILE" ]; then
            if (( ! LOG4SH_QUIET )); then
                # print to stdout
                if (( LOG4SH_DATE_LOG )) && (( LOG4SH_DATE )); then
                    printf "%b\n" "${LOG4SH_COLOR_BEGIN}${LOG4SH_FORMAT:-$(eval printf '%b' \"${LOG4SH_DEFAULT_SHORT_FORMAT}\")}${message}${LOG4SH_COLOR_OFF}"
                else
                    printf "%b\n" "${LOG4SH_COLOR_BEGIN}${LOG4SH_FORMAT:-$(eval printf '%b' \"${LOG4SH_DEFAULT_FORMAT}\")}${message}${LOG4SH_COLOR_OFF}"
                fi
            fi
            # print to file
            printf "%s\n" "${LOG4SH_FORMAT:-$(eval echo \"${LOG4SH_DEFAULT_FORMAT}\")}${message}" >> $LOG4SH_FILE
        fi
    fi
}

_log4sh_dispatch(){
    # only continues if the loglevel isn't squelching the log
    typeset _log_message="$@"

    LOG4SH_LEVEL=${LOG4SH_LEVEL:-'TRACE'}
    (( LOG4SH_COLOR )) && LOG4SH_COLOR_OFF=$LOG4SH_DEFAULT_COLOR

    if [[ ${LOG4SH_LEVEL} == 'TRACE' || ${LOG4SH_LEVEL} == 'ALL' ]];then
        _log4sh_do_dispatch "${_log_message}"
    elif [[ ${LOG4SH_LEVEL} == 'DEBUG' ]]; then
        if [[ ${_LOG_LVL} = @(DEBUG|INFO|WARN|ERROR|FATAL) ]]; then
            _log4sh_do_dispatch "${_log_message}"
        fi
    elif [[ ${LOG4SH_LEVEL} == 'INFO' ]]; then
        if [[ ${_LOG_LVL} = @(INFO|WARN|ERROR|FATAL) ]]; then
            _log4sh_do_dispatch "${_log_message}"
        fi
    elif [[ ${LOG4SH_LEVEL} == 'WARN' ]]; then
        if [[ ${_LOG_LVL} = @(WARN|ERROR|FATAL) ]]; then
            _log4sh_do_dispatch "${_log_message}"
        fi
    elif [[ ${LOG4SH_LEVEL} == 'ERROR' ]]; then
        if [[ ${_LOG_LVL} = @(ERROR|FATAL) ]]; then
            _log4sh_do_dispatch "${_log_message}"
        fi
    elif [[ ${LOG4SH_LEVEL} == 'FATAL' ]]; then
        if [[ ${_LOG_LVL} == 'FATAL' ]]; then
            _log4sh_do_dispatch "${_log_message}"
        fi
    elif [[ ${_LOG_LVL} == 'DEBUG' && -n "$LOG4SH_DEBUG_LOG" ]] && (( LOG4SH_DEBUG_LOG )); then
        _log4sh_do_dispatch "${_log_message}"
    elif [[ ${LOG4SH_LEVEL} == 'DEBUG' ]]; then
        return
    fi
}

_log4sh(){
    # always sends message regardless of squelch level
    _log4sh_dispatch "$@"
}

_log4sh_level(){
#     typeset _log_date
    typeset _log_message="$@"
#     if [ -n "$LOG4SH_DATE" ] && (( LOG4SH_DATE )); then
#         _log_date=$(_log4sh_date -u ${LOG4SH_DATE_FORMAT:-$LOG4SH_DEFAULT_DATE_FORMAT} -d @${_LOG_STAMP:-$(_log4sh_date +%s.%N)})
#         _log_date="$_log_date "
#     else
#         _log_date=''
#     fi
#     if [[ -n "$LOG4SH_FORMAT" && ! $LOG4SH_FORMAT = @(* ) ]]; then
#         LOG4SH_FORMAT="$LOG4SH_FORMAT "
#     fi
#     _log_message=$(printf "%b\n" "${LOG4SH_FORMAT:-${_log_date}${_LOG_LVL} - }$*")
#     _log_message=$(printf "%b\n" "${_LOG_LVL} - $*")
    _log4sh "${_log_message}"
}

log_fatal(){
    (( LOG4SH_COLOR )) && LOG4SH_COLOR_BEGIN=$LOG4SH_FATAL_COLOR || LOG4SH_COLOR_BEGIN=''
    typeset _LOG_LVL="FATAL"
    typeset _LOG_FUNC=${FUNCNAME[1]}
    typeset _LOG_FILE=${0}
    typeset _LOG_LINE=${LINENO}
    typeset _LOG_SECONDS=${SECONDS}
    typeset _LOG_STAMP=$(_log4sh_date +%s.%N)
    _log4sh_level "$@"
}
FATAL() {
    log_fatal "$@"
}

log_die(){
    log_fatal "$@"
    exit 200
}
DIE() {
    log_die "$@"
}

log_error(){
    (( LOG4SH_COLOR )) && LOG4SH_COLOR_BEGIN=$LOG4SH_ERROR_COLOR || LOG4SH_COLOR_BEGIN=''
    typeset _LOG_LVL="ERROR"
    typeset _LOG_FUNC=${FUNCNAME[1]}
    typeset _LOG_FILE=${0}
    typeset _LOG_LINE=${LINENO}
    typeset _LOG_SECONDS=${SECONDS}
    typeset _LOG_STAMP=$(_log4sh_date +%s.%N)
    _log4sh_level "$@"
}
ERROR() {
    log_error "$@"
}

LOGEXIT() { #{{{
    ERROR "$@"
    exit 1
} #}}}
log_warn(){
    (( LOG4SH_COLOR )) && LOG4SH_COLOR_BEGIN=$LOG4SH_WARN_COLOR || LOG4SH_COLOR_BEGIN=''
    typeset _LOG_LVL="WARN"
    typeset _LOG_FUNC=${FUNCNAME[1]}
    typeset _LOG_FILE=${0}
    typeset _LOG_LINE=${LINENO}
    typeset _LOG_SECONDS=${SECONDS}
    typeset _LOG_STAMP=$(_log4sh_date +%s.%N)
    _log4sh_level "$@"
}
WARN() {
    log_warn "$@"
}

log_info(){
    (( LOG4SH_COLOR )) && LOG4SH_COLOR_BEGIN=$LOG4SH_INFO_COLOR || LOG4SH_COLOR_BEGIN=''
    typeset _LOG_LVL="INFO"
    typeset _LOG_FUNC=${FUNCNAME[1]}
    typeset _LOG_FILE=${0}
    typeset _LOG_LINE=${LINENO}
    typeset _LOG_SECONDS=${SECONDS}
    typeset _LOG_STAMP=$(_log4sh_date +%s.%N)
    _log4sh_level "$@"
}
log(){
    log_info "$@"
}
INFO() {
    log_info "$@"
}

log_debug(){
    (( LOG4SH_COLOR )) && LOG4SH_COLOR_BEGIN=$LOG4SH_DEBUG_COLOR || LOG4SH_COLOR_BEGIN=''
    typeset _LOG_LVL="DEBUG"
    typeset _LOG_FUNC=${FUNCNAME[1]}
    typeset _LOG_FILE=${0}
    typeset _LOG_LINE=${LINENO}
    typeset _LOG_SECONDS=${SECONDS}
    typeset _LOG_STAMP=$(_log4sh_date +%s.%N)
    _log4sh_level "$@"
}
DEBUG() {
    log_debug "$@"
}

log_trace() {
    (( LOG4SH_COLOR )) && LOG4SH_COLOR_BEGIN=$LOG4SH_TRACE_COLOR || LOG4SH_COLOR_BEGIN=''
    typeset _LOG_LVL="TRACE"
    typeset _LOG_FUNC=${FUNCNAME[1]}
    typeset _LOG_FILE=${0}
    typeset _LOG_LINE=${LINENO}                 # doesn't work under Ksh, why?
    typeset _LOG_SECONDS=${SECONDS}
    typeset _LOG_STAMP=$(_log4sh_date +%s.%N)
    _log4sh_level "$@"
}
TRACE() {
    log_trace "$@"
}

