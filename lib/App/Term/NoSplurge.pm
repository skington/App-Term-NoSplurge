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

=head1 DESCRIPTION

We've all been there. You run something in your terminal, and suddenly your
screen goes haywire, a metric shedload of nonsense following I<another> metric
shedload of similar nonsense. Something, somewhere, has gone horribly wrong.

Because computers are stupid, the reason for all of this is probably to be
found very early on in the output of the poor unsuspecting program you just
ran. You just have to I<find> the start of the verbiage your scrollback is
now full of.

This is where App::Term::NoSplurge comes in. At its simplest, prefix any
command-line invocation with C<nosplurge> and the output of the resulting
command will be monitored for runaway terminal-spamming. As long as the amount
of output is limited in quantity and time, everything proceeds as normal;
but if there's ever a sudden increase in output, everything is piped to your
configured pager instead.

=cut

1;
