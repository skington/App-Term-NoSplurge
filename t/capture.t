#!/usr/bin/env perl

use strict;
use warnings;

use lib::abs;
use Capture::Tiny;
use English qw(-no_match_vars);
use Test::More;

use App::Term::NoSplurge;

my $test_bin_dir = lib::abs::path('./bin');
my @nosplurge_incantation = (
    $EXECUTABLE_NAME, '-I',
    lib::abs::path('../lib'),
    lib::abs::path('../bin/nosplurge')
);

subtest('We can handle a script that just outputs to STDOUT', \&test_stdout);
subtest('We can handle output to both STDOUT and STDERR', \&test_commingled);
done_testing();

# A simple script that outputs a small amount of data to STDOUT is
# correctly passed through without modification.

sub test_stdout {
    my %capture = _capture('minimal-stdout.pl');

    # The base program behaves like we expect.
    like(
        $capture{base_stdout},
        qr/brillig .+ borogoves .+ have \s to \s do/xsm,
        'We get a bit of Jabberwocky to STDOUT'
    );
    is(ord(substr(Encode::decode('UTF8', $capture{base_stdout}), 0, 1)),
        0x2019,
        'We got a Unicode right single quotation mark in the UTF8');
    is($capture{base_stderr}, '', 'Nothing spat out to STDERR');
    is($capture{base_exit},   0,  'Ordinary exit code');

    # As does the output filtered through nosplurge.
    is($capture{nosplurge_stdout}, $capture{base_stdout},
        'Nosplurge: same STDOUT as the base program');
    is($capture{nosplurge_stderr}, '', 'Still nothing spat out to STDERR');
    is($capture{nosplurge_exit},   0,  'Still an ordinary exit code');
}

# A script which outputs a small amount of data, to both STDOUT and STDERR,
# is passed through correctly, but with STDOUT and STDERR collapsed.

sub test_commingled {
    my %capture = _capture('minimal-commingled.pl');

    # The base program spits out stuff alternately to STDOUT and STDERR,
    # so depending on which stream you focus on you get one side of the duet
    # or the other.
    like(
        $capture{base_stdout},
        qr/^
            [^\n]+ \s hurdle \n
            [^\n]+ \s sweater \n
            [^\n]+ \s anything \n
            No
        /xsm,
        'Base script: STDOUT contains the male part'
    );
    like($capture{base_stderr},
        qr/^
            [^\n]+ \s girdle \n
            [^\n]+ \s better \n
            [^\n]+ \s bake \s a \s pie \? \n
            Neither \s can \s I
        /xsm,
        'Base script: STDERR contains the female part'
    );
    is($capture{base_exit}, 0, 'Despite animus, the base script ends up fine');

    # Nosplurge lumps everything together.
    like(
        $capture{nosplurge_stdout},
        qr/
            hurdle .+ girdle .+ sweater .+ better .+
            anything .+ pie .+ No .+ Neither
        /xsm,
        'Nosplurge: STDOUT and STDERR are mixed together, in order'
    );
    is($capture{nosplurge_stderr}, '', 'So nothing left in STDERR');
    is($capture{nosplurge_exit}, 0, 'And everything is still fine');
}

# Supplied with a script name, returns a hash of data containing the output
# to STDOUT, STDERR and the exit code, for both the base script and for the
# script run through nosplurge.

sub _capture {
    my ($script_name) = @_;

    my %capture;
    @capture{qw(base_stdout base_stderr base_exit)} = Capture::Tiny::capture {
        system($EXECUTABLE_NAME, "$test_bin_dir/$script_name");
    };
    @capture{qw(nosplurge_stdout nosplurge_stderr nosplurge_exit)}
        = Capture::Tiny::capture {
        system(@nosplurge_incantation, "$test_bin_dir/$script_name");
        };
    return %capture;
}
