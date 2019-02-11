
if ! type local 1>/dev/null 2>&1; then
    alias local1=typeset
fi

var=global

function foo {
    local1 var=foo
    printf "var from func foo: $var\n"
}

bar() {
    local1 var=bar
    printf "var from func bar: $var\n"
}

printf "var from code: $var\n"
foo
printf "var after func foo: $var\n"
bar
printf "var after func bar: $var\n"
