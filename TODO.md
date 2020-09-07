# TODO list for App::Term::NoSplurge

## Basic functionality

Take command-line arguments, pass them to system, pass through STDOUT
and STDERR.

If there's too much output (e.g. 25 lines in a second), take the remembered
output and pass it to a pager, via a pipe so more things can be added in real
time.

Output "Nosplurge to the rescue!" or something when we decide to send output
to a pager instead.

## Testing

No idea how to test the base case.

Test that input is captured and redirected: different output depending on
input, so we know that we connected it up. After a base case, run a script that
blocks on input, so we know that it's accepting our input; and have it e.g.
sprew out loads of stuff in the case of one input but not the other,
so we know we affected the result.

Date mocking to test the trigger of "OK, it's pager time".

Set up a "pager" that just dumps what it's fed to a temporary file.

When the pager quits, dump the last few lines; and the first few lines if
the first few lines were emitted so fast that they were never output.
(Although is that even possible?)

## Documentation

Explain the interaction with the shell, e.g. say FOO=bar nosplurge command-line
stuff etc. 

It's pointless to include output redirection (> or 2> etc.) because the entire
point of nosplurge is to hijack STDOUT and STDERR if they're going to be
spammy. Probably the best bet is to say alias prove="nosplurge prove" in your
.bashrc or something.

Caveat about non-Unix systems.
