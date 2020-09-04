package App::Term::NoSplurge;

use strict;
use warnings;

=head1 NAME

App::Term::NoSplurge - be ready to summon a pager if your terminal goes haywire

=head1 VERSION

This is version 0.001.

=cut

our $VERSION = '0.001';
$VERSION = eval $VERSION;

=head1 SYNOPSIS

 $ nosplurge prove test-that-might-go-haywire.t

=head1 DESCRIPTION

We've all been there. You run something in your terminal, and suddenly your
screen goes haywire, a metric shedload of nonsense following one or more
I<other> metric shedloads of similar nonsense.

Three things are simultaneously, depressingly, likely:

=over

=item 1

Something has gone horribly, horribly wrong.

=item 2

The clue to what went wrong is probably at the start of this slew of
error messages and other chatter. All other errors are almost certainly
knock-on effects and can, for now, be safely ignored.

=item 3

You have no where in your scrollback that start I<is> anymore.

=back

This is where App::Term::NoSplurge comes in. At its simplest, prefix any
command-line invocation with C<nosplurge> and the output of the resulting
command will be monitored for runaway terminal-spamming. As long as the amount
of output is limited in quantity and time, everything proceeds as normal;
but if there's ever a sudden increase in output, everything is piped to your
configured pager instead.

=cut

1;
