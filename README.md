log4sh
======

A shell logging library, based on [log4bats](https://github.com/goozbach/log4bats).

## Install

    make install PREFIX=/usr

## Requirements

To create documentation for wiki you need [Pod-Simple-Wiki](http://search.cpan.org/~jmcnamara/Pod-Simple-Wiki/).
pod2man and pod2text belong to Perl

## USAGE

```
    . log4sh.sh [-l level] [-t 0|1] [-d 0|1] [-c 0|1] [-qhup] [-f file] [-d path to GNU date]
```

## OPTIONS

    -l level
    The priority of the log message, logging level.
    -t 0|1
    Switch on/off data/timestamp
    -T 0|1
    Switch on/off data/timestamp only in a log file
    -D 0|1
    Write DEBUG information to logfile
    -c 0|1
    Switch on/off colors.
    -q
    Be quiet.
    -f file
    The path to the log file.
    -d file
    The path to the GNU date if different from _/opt/freeware/bin/date_ or there is no GNU date in default PATH.
    -p
    Use in-built Perl script which replace GNU date. It works more slower.
    -u
    Show full usage with additional information
    -h
    show help

To process new parameters, you have to invoke log4sh_init function with new ones.

To unset all functions you have to invoke log4sh_deinit function.

See also [CONTROL VARIABLES](#control-variables). For incorrect option it returns 1.

## EXAMPLES


```
    $ . log4sh.sh
    $ INFO lorem ipsum
    2016-11-29-14:07:42 [INFO] lorem ipsum

    $ FATAL another fatal error
    2016-11-29-14:08:20 [FATAL] another fatal error

    $ LOG4SH_DATE=0 # disable timestamp
    [FATAL] another fatal error

    $ LOG4SH_LEVEL=ERROR # logging only error, fatal

    $ LOG4SH_FILE='some_program.log'
    $ INFO 'a message' # write also to log file with timestamp
    [INFO] a message
```

## FUNCTIONS

There are following functions:

* log_fatal, FATAL
* log_die, DIE
    As log_fatal, but it also exits from shell.
* log_error, ERROR
* LOGEXIT
    As log_die or DIE, but it exits or returns from a function.
* log_warn, WARN
* log_info, INFO
* log_debug, DEBUG
* log_trace, TRACE
* log4sh_init - initialize log4sh control variables

## CONTROL VARIABLES

These variables can be overwritten in a shell.

* LOG4SH_DATE=1

Date/timestamp before each message ( to STDOUT and a log file )

* LOG4SH_DATE_LOG=1

    Print date/timestamp only to a log file

* LOG4SH_DATE_FORMAT="+%FT%TZ"

    Default format for a timestamp. Same as format for [date(1)](date(1)).

* LOG4SH_DATE_BIN=''

    Absolute path to GNU date. If you use this library on AIX machine you should define absolute path to the GNU date program.
    The library checks: path /opt/freeware/bin/date for existing and date for default PATH. The GNU date supports _--version_ switch.

* LOG4SH_FORMAT=''

    A format for the header of each message. It could overwrite the default format: 'timestamp [log level]'

* LOG4SH_COLOR=1

    Does it use colors? There are following default colors:

* ERROR   - red
* FATAL   - red
* INFO    - white
* SUCCESS - green
* WARN    - yellow
* DEBUG   - blue
* TRACE   - cyan

There are following defined colors:

 * LOG4SH_COLOR_BOLD="^[[1;37m"
 * LOG4SH_COLOR_RED="^[[1;31m"
 * LOG4SH_COLOR_WHITE="^[[1;37m"
 * LOG4SH_COLOR_GREEN="^[[1;32m"
 * LOG4SH_COLOR_YELLOW="^[[1;33m"
 * LOG4SH_COLOR_BLUE="^[[1;34m"
 * LOG4SH_COLOR_CYAN="^[[1;36m"
 * LOG4SH_COLOR_OFF="^[[0m"

 * LOG4SH_ERROR_COLOR="$LOG4SH_COLOR_RED"
 * LOG4SH_FATAL_COLOR="$LOG4SH_COLOR_RED"
 * LOG4SH_INFO_COLOR="$LOG4SH_COLOR_WHITE"
 * LOG4SH_SUCCESS_COLOR="$LOG4SH_COLOR_GREEN"
 * LOG4SH_WARN_COLOR="$LOG4SH_COLOR_YELLOW"
 * LOG4SH_DEBUG_COLOR="$LOG4SH_COLOR_BLUE"
 * LOG4SH_TRACE_COLOR="$LOG4SH_COLOR_CYAN"

You can also overwrite them.

* LOG4SH_QUIET=0

    Does it be quiet? It is not equivalent of NONE level. This disables logging only to STDOUT. NONE level disables all messages, even to log file.

* LOG4SH_LEVEL=INFO

The priority of the log message, logging level. Same as Log4Perl and Log4J. There are following and allowed levels:

* ALL (synonym for TRACE)
* TRACE
* DEBUG
* INFO
* WARN
* ERROR
* FATAL
* NONE (no logging)

Eeach level includes the one below. Ie. **WARN** will print **WARN**, **ERROR**, and **FATAL** messages.

* LOG4SH_FILE=''

    Where messages are saved.

## Todo

* [x] create initialize function like for Log::Log4perl
* [x] replace \_log4sh_date function with something better
* [x] replace global variables with local

## Positional parameters - deprecated

If your script parse positional argument you should to do something like this:

```bash
#!/usr/bin/env bash
PROGRAM_NAME=$(basename "$0")
PROGRAM_OPTIONS='h'
PROGRAM_INPUT_PARAMS=("$@")
# reseting positional parameters
set --
LEVEL=INFO

source_log4sh() {
    typeset logFile=$1
    # searching for the lib in PATH env
    if type log4sh.sh &>/dev/null; then
        . log4sh.sh ${logFile:+-f $logFile} -t 0 -l $LEVEL || { printf '%s\n' "Error during sourcing of log4sh.sh"; exit 1; }
        DEBUG "The library log4sh has been loaded from the PATH"
    # searching in ~/lib/sh/log4sh directory
    elif [ -r ~/lib/sh/log4sh/log4sh.sh ]; then
        . ~/lib/sh/log4sh/log4sh.sh ${logFile:+-f $logFile} -t 0 -l $LEVEL || { printf '%s\n' "Error during sourcing of ~/lib/log4sh.sh"; exit 1; }
        DEBUG "The library log4sh has been loaded from ~/lib/sh/log4sh/log4sh.sh"
    else
        : printf '%s\n' "Could not read log4sh.sh library. A workaround will be used." >&2
        if [ "$(type -t command_not_found_handle)" = function ]; then
            command_not_found_handle_previous=$(declare -f command_not_found_handle | tail -n +3 | head -n -1)
            unset -f command_not_found_handle
        fi
        command_not_found_handle() {
            export TEXTDOMAIN=command-not-found
            typeset command
            case $1 in
                INFO|WARN|ERROR)
                    command=$1
                    shift
                    printf '%s\n' "$command - $@"
                    return
                    ;;
                DEBUG)
                    if [ "$LEVEL" = 'DEBUG' ]; then
                        command=$1
                        shift
                        printf '%s\n' "$command - $@"
                    fi
                    return
                    ;;
            esac
            if [ -n "$command_not_found_handle_previous" ]; then
                eval "$command_not_found_handle_previous"
                unset command_not_found_handle_previous
            fi
        }
    fi
}

source_shell-includes() {
    if [ -r ~/lib/sh/shell-includes/shell-includes.sh ]; then
        . ~/lib/sh/shell-includes/shell-includes.sh
    fi
}

source_shell-includes
source_log4sh $PROGRAM_NAME.log

# Parse command line arguments
options=$(getopt $PROGRAM_OPTIONS "${PROGRAM_INPUT_PARAMS[*]}" 2>/dev/null)
retval=$?
if (( retval )); then
    _usage
fi
eval set -- "$options"
unset options

while [[ "$1" != -- ]]; do
    case $1 in
        -h)
            _help
            ;;
        *)
            _usage
            ;;
    esac
done
WARN "Testing log4sh function"
```

