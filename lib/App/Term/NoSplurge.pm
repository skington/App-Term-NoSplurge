package App::Term::NoSplurge;

use strict;
use warnings;

use IPC::Open3;
use IO::Select;
use Symbol;

=head1 NAME

App::Term::NoSplurge - summons a pager if your terminal goes haywire

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

You have no idea where in your scrollback that start I<is> anymore.

=back

This is where App::Term::NoSplurge comes in. At its simplest, prefix any
command-line invocation with C<nosplurge> and the output of the resulting
command will be monitored for runaway terminal-spamming. As long as the amount
of output is limited in quantity and time, everything proceeds as normal;
but if there's ever a sudden increase in output, everything is piped to your
configured pager instead.

=head2 Functions

=head3 run

Calls L<capture_command> with the contents of C<@ARGV>.

=cut

sub run {
    capture_command(@ARGV);
}

=head3 capture_command

 In: @system_params

Calls (effectively) system(@system_params), capturing STDOUT and STDERR
and spitting the combined results out to STDOUT.

=cut

sub capture_command {
    my @system_params = @_;

    # Run the specified command as a child process.
    my $stdin; # FIXME: can we say <& somehow instead?
    my ($stdout, $stderr) = map { Symbol::gensym() } 1..2;
    my $pid = open3($stdin, $stdout, $stderr, join(' ', @system_params));

    # Poll STDOUT and STDERR until they're both closed.
    my $selector = IO::Select->new;
    $selector->add($stdout, $stderr);
    while (my @fh_ready = $selector->can_read) {
        for my $fh (@fh_ready) {
            my $buffer     = '';
            my $chunk_size = 256;
            read_attempt:
            while (1) {
                use Carp;
                my $len = sysread($fh, $buffer, $chunk_size, length($buffer));
                if ($len == 0) {
                    $selector->remove($fh);
                    last read_attempt;
                }
                print $buffer;
                $buffer = '';
                last read_attempt if $len < $chunk_size;
            }
        }
    }

    # Make sure to reap the child process.
    waitpid($pid, 0);
}

=head1 LIMITATIONS

No attempt is made to deal with STDIN. The use case for this utility is where
you've run something that proceeds without user intervention, but now use
intervention is I<sadly needed>.

Whether the command invoked spams to STDOUT and/or STDERR is gleefully ignored.
All captured output is spat out to STDOUT, and if it ever needed to be captured
to a file, STDOUT and STDERR are commingled. This mimics the behaviour of
running a script from the shell, where it I<doesn't matter>; by default you'll
see both streams anyway.

=head1 AUTHOR

Sam Kington <skington@cpan.org>

The source code for this module is hosted on GitHub
L<https://github.com/skington/App-Term-Nosplurge> - this is probably the
best place to look for suggestions and feedback.

=head1 COPYRIGHT

Copyright (c) 2020 Sam Kington.

=head1 LICENSE

This library is free software and may be distributed under the same terms as
perl itself.


=cut

1;
