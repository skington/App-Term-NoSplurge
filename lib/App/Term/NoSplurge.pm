package App::Term::NoSplurge;

use strict;
use warnings;

use File::Temp qw(:seekable);
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
but if there's ever a sudden increase in output, splurge detection kicks in:

=over

=item *

Output of the script stops being echoed to your terminal.

=item *

Once the script has finished spewing verbiage, the entirety of the output
(including the initial few lines' worth) is passed to your configured
pager.

=item *

Once the pager quits, the last few lines' worth are echoed to your terminal,
in case there was anything useful at the end (e.g. a summary of test failures).

=back

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

# The amount of splurge that can tolerated. Note that we don't expect
# that someone's terminal *is* 25x80; rather, if there's more output than
# *would* fit in such a terminal, then that's clearly too much.
my $SPLURGE_LINES      = 25;
my $POST_SPLURGE_LINES = 10;
my $LINE_WIDTH         = 80;

sub capture_command {
    my @system_params = @_;

    # Run the specified command as a child process.
    my $stdin; # FIXME: can we say <& somehow instead?
    my ($stdout, $stderr) = map { Symbol::gensym() } 1..2;
    my $pid = open3($stdin, $stdout, $stderr, join(' ', @system_params));

    # Poll STDOUT and STDERR until they're both closed.
    my $selector = IO::Select->new;
    $selector->add($stdout, $stderr);

    # By default print lines we see until we reach the splurge threshold;
    # at which point we should remember the stuff we didn't print, so we can
    # print the last few lines for context at the end.
    my ($output, $previous_line, $lines_seen);
    my @hidden_lines;
    my $handle_line;
    $handle_line = sub {
        print @_;
        if (($lines_seen += @_) >= $SPLURGE_LINES) {
            $handle_line = sub { push @hidden_lines, @_; };
        }
    };
    while (my @fh_ready = $selector->can_read) {
        for my $fh (@fh_ready) {
            # Read into a buffer chunk by chunk rather than e.g. reading until
            # the next newline so (a) we don't block, and (b) we detect before
            # even a newline that something is spitting out a huge wodge of
            # nonsense.
            my $buffer     = '';
            my $chunk_size = 256;
            read_attempt:
            while (1) {
                use Carp;
                # Read into our buffer. If there was nothing to read, that's
                # a sign that there's definitely nothing to read any further.
                my $len = sysread($fh, $buffer, $chunk_size, length($buffer));
                if ($len == 0) {
                    $selector->remove($fh);
                    last read_attempt;
                }
                
                # Remember what we read, in case we need to spit this stuff
                # out to a temporary file and pass it to a pager.
                $output .= $buffer;
                
                # Work out which lines we got (split long lines into a
                # rough line's worth for the purpose of measurement).
                my @lines_found;
                if (defined $previous_line) {
                    $buffer = $previous_line . $buffer;
                }
                line:
                while ($buffer =~ s{ \G ( [^\n]* \n) }{}xsm) {
                    my $line = $1;
                    # Consider a line width's worth of characters to be
                    # the same as an actual line. Note that this ignores
                    # Unicode, but it's just a heuristic so it *should*
                    # be OK?
                    while (length($line) >= $LINE_WIDTH) {
                        push @lines_found, substr($line, 0, $LINE_WIDTH);
                        substr($line, 0, $LINE_WIDTH) = '';
                    }
                    # If we have a line feed after all of this (or instead
                    # of all of this), this is also a line.
                    if ($line =~ m{ \n $}xsm) {
                        push @lines_found, $line;
                    }
                }

                # Remember anything that didn't count towards a line
                # for next time.
                $previous_line = $buffer;
                $buffer = '';
                
                # And handle the lines we extracted from this buffer.
                for my $line (@lines_found) {
                    $handle_line->($line);
                }

                # If we didn't read the entirety of our buffer, that was clearly
                # all there *was* to read, so we're done here.
                # FIXME: what if we read in exactly as much text as will in the
                # buffer because that's *all there was*? Should we check
                # $selector->can_read again?
                last read_attempt if $len < $chunk_size;
            }
        }
    }

    # Make sure to reap the child process.
    waitpid($pid, 0);

    # If we decided at some point that splurge-like activity had been
    # detected, pass the output we gobbled up to the user's preferred
    # pager.
    if (@hidden_lines) {
        # We stopped printing output when we detected a splurge, but we
        # still kept collecting it all, so say that we did this, and pass
        # the whole lot to the pager.
        ### TODO: what do we do if $ENV{PAGER} isn't set?
        ### TODO: let people keep the output if it splurged.
        print "### Splurge detected! All output passed to $ENV{PAGER}\n";
        my $fh = File::Temp->new(TEMPLATE => 'nosplurge-XXXXX', TMPDIR => 1);
        $fh->autoflush;
        $fh->print($output);
        $fh->close;
        ### TODO: use /proc/fd... if we can instead, because that's more secure?
        system($ENV{PAGER}, $fh->filename);
        
        # Follow up with a summary of the last few lines of the output,
        # so there's context in scrollback.
        if (@hidden_lines > 10) {
            print @hidden_lines[-10..-1];
        } else {
            print @hidden_lines;
        }
    }
}

=head1 LIMITATIONS

No attempt is made to deal with STDIN. The use case for this utility is where
you've run something that proceeds without user intervention, but now user
intervention is I<sadly needed>.

Whether the command invoked spams to STDOUT and/or STDERR is gleefully ignored.
All captured output is spat out to STDOUT, and if it ever needed to be captured
to a file, STDOUT and STDERR are commingled. This mimics the behaviour of
running a script from the shell, where it I<doesn't matter>; by default you'll
see both streams anyway.

How much output should be counted as a splurge is determined by a
rough-and-ready heuristic of "if it fills a 80x25 terminal, it's too much".
This doesn't pay attention to Unicode, so it's possible that e.g. multi-byte
UTF8-encoded output will be corrupted.

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
