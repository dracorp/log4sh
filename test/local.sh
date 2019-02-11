
alias local=typeset
eval local

var=global

function foo {
    eval local var=foo
    printf "var from func foo: $var\n"
}

bar() {
    eval local var=bar
    printf "var from func bar: $var\n"
}

printf "var from code: $var\n"
foo
printf "var after func foo: $var\n"
bar
printf "var after func bar: $var\n"
