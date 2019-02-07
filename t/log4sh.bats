#!../lib/bats/bin/bats

LOG4SH_COLOR=0
load ../log4sh.sh

@test "INFO level" {
    result=$(INFO 'lorem ipsum')
    [ "$result" == "INFO - lorem ipsum" ]
}

@test "WARN level" {
    result=$(WARN 'lorem ipsum')
    [ "$result" == "WARN - lorem ipsum" ]
}

@test "ERROR level" {
    result=$(ERROR 'lorem ipsum')
    [ "$result" == "ERROR - lorem ipsum" ]
}

@test "DEBUG level" {
    LOG4SH_LEVEL=DEBUG
    result=$(DEBUG 'lorem ipsum')
    [ "$result" == "DEBUG - lorem ipsum" ]
}

@test "TRACE level" {
    LOG4SH_LEVEL=TRACE
    result=$(TRACE 'lorem ipsum')
    [ "$result" == "TRACE - lorem ipsum" ]
}

