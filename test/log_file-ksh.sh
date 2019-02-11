#!/usr/bin/env ksh

log4sh(){
    . ../log4sh.sh \
        "$@" \
        || { printf "There was an error while sourcing log4sh.sh"; exit 1; }
}
:>sh.log
log4sh
time {
    INFO "Lorem ipsum"; \
    DEBUG Lorem ipsum dolor sit amet; \
    ERROR "Lorem ipsum"; \
    WARN "Lorem ipsum"; \
    INFO Lorem ipsum dolor sit amet.; \
}

log4sh -p
time {
    INFO "Lorem ipsum"; \
    DEBUG Lorem ipsum dolor sit amet; \
    ERROR "Lorem ipsum"; \
    WARN "Lorem ipsum"; \
    INFO Lorem ipsum dolor sit amet.; \
}

log4sh
INFO "Lorem ipsum"
DEBUG "Lorem ipsum"

log4sh -D
INFO "Lorem ipsum"
DEBUG "Lorem ipsum"

log4sh -D -f sh.log -p
INFO "Lorem ipsum"
DEBUG "Lorem ipsum"

echo LOG4SH_COLOR:$LOG4SH_COLOR
log4sh_deinit
echo LOG4SH_COLOR:$LOG4SH_COLOR

