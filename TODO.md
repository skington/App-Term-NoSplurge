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

Date mocking to test the trigger of "OK, it's pager time".

Set up a "pager" that just dumps what it's fed to a temporary file.

When the pager quits, dump the last few lines; and the first few lines if
the first few lines were emitted so fast that they were never output.
(Although is that even possible?)