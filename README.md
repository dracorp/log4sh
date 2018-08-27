# log4sh
A Bash logging library based on [goozbach/log4bats](https://github.com/goozbach/log4bats). At the beginning it was fork but now is almost completely rewritten.

## Install

    make install PREFIX=/usr

## Requirements

To create documentation for wiki you need [Pod-Simple-Wiki](http://search.cpan.org/~jmcnamara/Pod-Simple-Wiki/).
pod2man and pod2text belong to Perl

## Todo

* [ ] create initialize function like for Log::Log4perl
* [ ] replace \_log4sh_date function with something better
* [ ] replace global variables with local

## Positional parameters

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

