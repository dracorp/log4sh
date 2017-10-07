#===============================================================================
# NAME
#
# SYNOPSIS
#       . log4sh.sh [-l level] [-t 0|1] [-d 0|1] [-c 0|1] [-qh] [-f file] [-b path to GNU date]
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
#       -q          - be quiet
#       -f file     - a log file
#       -b file     - a path to GNU date
#       -p          - use Perl instead GNU date, it requires following modules: Time::HiRes and POSIX
#
# BUGS
#       To prevent mixing of positional arguments source the file inside
#       a function, eg.
#
#       log4sh(){ . ./log4sh.sh || exit 1 }
#       log4sh
#
#       Without this log4sh.sh modifies positional parameters.
#       TODO: fix it
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
# AUTHOR
#       Piotr Rogoza <piotr.r.public@gmail.com
#
#===============================================================================

# if is_modern_ksh; then
#     LIB_DIRECTORY="$( cd "$( dirname "$( readlink "${.sh.file}" || echo "${.sh.file}" )" )" && pwd -P )"
# else
#     # set to real directory with lib files and util directory
#     printf "You are using old version of Ksh, beware! Set LIB_DIRECTORY to real directory with libraries' files.\n" >&2
#     LIB_DIRECTORY="$HOME/bin/lib"
# fi

_perlDate="/tmp/perlDate-$$.pl"
if [ -n "$BASH_VERSION" ]; then
    shopt -s extglob
    trap _clean_after_log4sh SIGINT SIGTERM EXIT
else
    # Probably Ksh
    trap _clean_after_log4sh INT TERM EXIT
fi
_clean_after_log4sh() {
    if [[ -n "$_perlDate" && -f "$_perlDate" ]]; then
        rm -f "$_perlDate"
    fi
}
function _usage {
    printf "Usage:\n. log4sh.sh [-l level] [-t 0|1] [-T 0|1] [-c 0|1] [-qhD] [-f file] [-b path to GNU date]\n"
}
function _help {
    _usage
    printf "\t-l level - log level\n"
    printf "\t-t 0|1   - switch on/off data/timestamp\n"
    printf "\t-T 0|1   - switch on/off data/timestamp only in a log file\n"
    printf "\t-D       - switch on/off writing DEBUG to a log file\n"
    printf "\t-c 0|1   - switch on/off colors\n"
    printf "\t-q       - be quiet\n"
    printf "\t-f file  - path log file\n"
    printf "\t-d file  - path to GNU date\n"
    printf "\t-p       - use Perl replacment for GNU date, it's slower\n"
}

PROGRAM_OPTIONS='l:t:T:c:f:d:Dqp'
eval set -- $(getopt $PROGRAM_OPTIONS $* 2>/dev/null)
while [[ "$1" != -- ]]; do
    case $1 in
        -c) LOG4SH_COLOR=$2; shift ;;
        -d) LOG4SH_DATE_BIN=$2; shift ;;
        -f) LOG4SH_FILE=$2; shift ;;
        -l) LOG4SH_LEVEL=$2; shift ;;
        -t) LOG4SH_DATE=$2; shift ;;
        -T) LOG4SH_DATE_LOG=$2; shift ;;
        -D) LOG4SH_DEBUG_LOG=1 ;;
        -h|--help) _help; return 1;;
        -q) LOG4SH_QUIET=1 ;;
        -p) LOG4SH_DATE_BIN=perl ;;
        *) _usage; return 1 ;;
    esac
    shift
done
shift # remove --

# some default values, can be overwritten in shell
: ${LOG4SH_DATE=1}                            # do print timestamp?
: ${LOG4SH_DATE_LOG=1}                        # print timestamp only in log file
: ${LOG4SH_DATE_FORMAT="+%F-%T"}              # format of timestamp
: ${LOG4SH_COLOR=1}                           # do use color?
: ${LOG4SH_QUIET=0}                           # be quiet
: ${LOG4SH_LEVEL=INFO}                        # default log level
: ${LOG4SH_FORMAT=''}                         # instead it is used timestamp and loglevel
: ${LOG4SH_DATE_BIN=''}                       # path to GNU date
: ${LOG4SH_FILE=''}                           # a log file
: ${LOG4SH_DEBUG_LOG=0}                       # write DEBUG information to a log file

: ${LOG4SH_DEFAULT_COLOR="[0m"}             # color off
: ${LOG4SH_ERROR_COLOR="[1;31m"}            # red
: ${LOG4SH_FATAL_COLOR="[1;31m"}            # red
: ${LOG4SH_INFO_COLOR="[0m"}                # white
: ${LOG4SH_SUCCESS_COLOR="[1;32m"}          # green
: ${LOG4SH_WARN_COLOR="[1;33m"}             # yellow
: ${LOG4SH_DEBUG_COLOR="[1;34m"}            # blue
: ${LOG4SH_TRACE_COLOR="[1;36m"}
: ${LOG4SH_COLOR_ON=$LOG4SH_DEFAULT_COLOR}

if [[ -n "$LOG4SH_DATE_BIN" && $LOG4SH_DATE_BIN == 'perl' ]]; then
    _log4sh_date() {
#         $LIB_DIRECTORY/util/date.pl "$@"
#         return
# read -r -d '' _PERL_CODE << 'EOF'
        if [ ! -x "$_perlDate" ]; then
cat << 'EOF' > "$_perlDate"
#!/usr/bin/env perl
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
            chmod +x $_perlDate
        fi
        $_perlDate "$@"
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

_log_do_dispatch(){
    typeset message="$@"
    typeset _log_date
    if [ -n "$LOG4SH_DATE" ] && (( LOG4SH_DATE )); then
        _log_date=$(_log4sh_date -u ${LOG4SH_DATE_FORMAT:-"+%F-%T"} -d @${_LOG_STAMP:-$(_log4sh_date +%s.%N)})
        _log_date="$_log_date "
    else
        _log_date=
    fi
    if [[ -n "$LOG4SH_FORMAT" && ! $LOG4SH_FORMAT = @(* ) ]]; then
        LOG4SH_FORMAT="$LOG4SH_FORMAT "
    fi
    # Write DEBUG message to log file but only when:
    if [[ "$_LOG_LVL" = 'DEBUG' && $LOG4SH_LEVEL = $(INFO|WARN|ERROR|FATAL) && -n "$LOG4SH_FILE" ]] && (( LOG4SH_DEBUG_LOG )); then
        printf "%s\n" "${LOG4SH_FORMAT:-${_log_date}${_LOG_LVL} - }${message}" >> $LOG4SH_FILE
    else
        # Without logfile
        if [ -z "$LOG4SH_FILE" ]; then
            if (( ! LOG4SH_QUIET )); then
                printf "%s\n" "${LOG4SH_COLOR_ON}${LOG4SH_FORMAT:-${_log_date}${_LOG_LVL} - }${message}${LOG4SH_COLOR_OFF}"
            fi
        # With logfile
        elif [ -n "$LOG4SH_FILE" ]; then
            if (( ! LOG4SH_QUIET )); then
                # print to stdout
                if (( LOG4SH_DATE_LOG )) && (( LOG4SH_DATE )); then
                    printf "${LOG4SH_COLOR_ON}${LOG4SH_FORMAT:-${_LOG_LVL} - }${message}${LOG4SH_COLOR_OFF}\n"
                else
                    printf "${LOG4SH_COLOR_ON}${LOG4SH_FORMAT:-${_log_date_}${_LOG_LVL} - }${message}${LOG4SH_COLOR_OFF}\n"
                fi
            fi
            # print to file
            printf "%s\n" "${LOG4SH_FORMAT:-${_log_date}${_LOG_LVL} - }${message}" >> $LOG4SH_FILE
        fi
    fi
}

_log_dispatch(){
    # only continues if the loglevel isn't squelching the log
    typeset _log_message="$@"

    LOG4SH_LEVEL=${LOG4SH_LEVEL:-'TRACE'}
    (( LOG4SH_COLOR )) && LOG4SH_COLOR_OFF=$LOG4SH_DEFAULT_COLOR

    if [[ ${LOG4SH_LEVEL} == 'TRACE' || ${LOG4SH_LEVEL} == 'ALL' ]];then
        _log_do_dispatch "${_log_message}"
    elif [[ ${LOG4SH_LEVEL} == 'DEBUG' ]]; then
        if [[ ${_LOG_LVL} = @(DEBUG|INFO|WARN|ERROR|FATAL) ]]; then
            _log_do_dispatch "${_log_message}"
        fi
    elif [[ ${LOG4SH_LEVEL} == 'INFO' ]]; then
        if [[ ${_LOG_LVL} = @(INFO|WARN|ERROR|FATAL) ]]; then
            _log_do_dispatch "${_log_message}"
        fi
    elif [[ ${LOG4SH_LEVEL} == 'WARN' ]]; then
        if [[ ${_LOG_LVL} = @(WARN|ERROR|FATAL) ]]; then
            _log_do_dispatch "${_log_message}"
        fi
    elif [[ ${LOG4SH_LEVEL} == 'ERROR' ]]; then
        if [[ ${_LOG_LVL} = @(ERROR|FATAL) ]]; then
            _log_do_dispatch "${_log_message}"
        fi
    elif [[ ${LOG4SH_LEVEL} == 'FATAL' ]]; then
        if [[ ${_LOG_LVL} == 'FATAL' ]]; then
            _log_do_dispatch "${_log_message}"
        fi
    elif [[ ${_LOG_LVL} == 'DEBUG' && -n "$LOG4SH_DEBUG_LOG" ]] && (( LOG4SH_DEBUG_LOG )); then
        _log_do_dispatch "${_log_message}"
    elif [[ ${LOG4SH_LEVEL} == 'DEBUG' ]]; then
        return
    fi
}

_log(){
    # always sends message regardless of squelch level
    _log_dispatch "$@"
}

_log_level(){
#     typeset _log_date
    typeset _log_message="$@"
#     if [ -n "$LOG4SH_DATE" ] && (( LOG4SH_DATE )); then
#         _log_date=$(_log4sh_date -u ${LOG4SH_DATE_FORMAT:-"+%F-%T"} -d @${_LOG_STAMP:-$(_log4sh_date +%s.%N)})
#         _log_date="$_log_date "
#     else
#         _log_date=''
#     fi
#     if [[ -n "$LOG4SH_FORMAT" && ! $LOG4SH_FORMAT = @(* ) ]]; then
#         LOG4SH_FORMAT="$LOG4SH_FORMAT "
#     fi
#     _log_message=$(printf "%b\n" "${LOG4SH_FORMAT:-${_log_date}${_LOG_LVL} - }$*")
#     _log_message=$(printf "%b\n" "${_LOG_LVL} - $*")
    _log "${_log_message}"
}

log_fatal(){
    (( LOG4SH_COLOR )) && LOG4SH_COLOR_ON=$LOG4SH_FATAL_COLOR || LOG4SH_COLOR_ON=''
    typeset _LOG_LVL="FATAL"
    typeset _LOG_FUNC=${FUNCNAME[1]}
    typeset _LOG_FILE=${0}
    typeset _LOG_LINE=${LINENO}
    typeset _LOG_SECONDS=${SECONDS}
    typeset _LOG_STAMP=$(_log4sh_date +%s.%N)
    _log_level "$@"
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
    (( LOG4SH_COLOR )) && LOG4SH_COLOR_ON=$LOG4SH_ERROR_COLOR || LOG4SH_COLOR_ON=''
    typeset _LOG_LVL="ERROR"
    typeset _LOG_FUNC=${FUNCNAME[1]}
    typeset _LOG_FILE=${0}
    typeset _LOG_LINE=${LINENO}
    typeset _LOG_SECONDS=${SECONDS}
    typeset _LOG_STAMP=$(_log4sh_date +%s.%N)
    _log_level "$@"
}
ERROR() {
    log_error "$@"
}

LOGEXIT() { #{{{
    ERROR "$@"
    exit 1
} #}}}
log_warn(){
    (( LOG4SH_COLOR )) && LOG4SH_COLOR_ON=$LOG4SH_WARN_COLOR || LOG4SH_COLOR_ON=''
    typeset _LOG_LVL="WARN"
    typeset _LOG_FUNC=${FUNCNAME[1]}
    typeset _LOG_FILE=${0}
    typeset _LOG_LINE=${LINENO}
    typeset _LOG_SECONDS=${SECONDS}
    typeset _LOG_STAMP=$(_log4sh_date +%s.%N)
    _log_level "$@"
}
WARN() {
    log_warn "$@"
}

log_info(){
    (( LOG4SH_COLOR )) && LOG4SH_COLOR_ON=$LOG4SH_INFO_COLOR || LOG4SH_COLOR_ON=''
    typeset _LOG_LVL="INFO"
    typeset _LOG_FUNC=${FUNCNAME[1]}
    typeset _LOG_FILE=${0}
    typeset _LOG_LINE=${LINENO}
    typeset _LOG_SECONDS=${SECONDS}
    typeset _LOG_STAMP=$(_log4sh_date +%s.%N)
    _log_level "$@"
}
log(){
    log_info "$@"
}
INFO() {
    log_info "$@"
}

log_debug(){
    (( LOG4SH_COLOR )) && LOG4SH_COLOR_ON=$LOG4SH_DEBUG_COLOR || LOG4SH_COLOR_ON=''
    typeset _LOG_LVL="DEBUG"
    typeset _LOG_FUNC=${FUNCNAME[1]}
    typeset _LOG_FILE=${0}
    typeset _LOG_LINE=${LINENO}
    typeset _LOG_SECONDS=${SECONDS}
    typeset _LOG_STAMP=$(_log4sh_date +%s.%N)
    _log_level "$@"
}
DEBUG() {
    log_debug "$@"
}

log_trace() {
    (( LOG4SH_COLOR )) && LOG4SH_COLOR_ON=$LOG4SH_TRACE_COLOR || LOG4SH_COLOR_ON=''
    typeset _LOG_LVL="TRACE"
    typeset _LOG_FUNC=${FUNCNAME[1]}
    typeset _LOG_FILE=${0}
    typeset _LOG_LINE=${LINENO}                 # doesn't work under Ksh, why?
    typeset _LOG_SECONDS=${SECONDS}
    typeset _LOG_STAMP=$(_log4sh_date +%s.%N)
    _log_level "$@"
}
TRACE() {
    log_trace "$@"
}

