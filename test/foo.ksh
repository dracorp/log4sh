#!/usr/bin/env ksh

if ! type local >/dev/null 2>&1; then
    alias -x local='typeset'
fi

function foo {
    local foo=FOO
    echo "from func foo: $foo"
}
function bar {
    foo=BAR
    echo "from func bar: $foo"
}
foo
echo "from outside func: $foo"
bar
echo "from outside func: $foo"
