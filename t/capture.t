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

subtest('Basic functionality', \&test_basics);
done_testing();

sub test_basics {
    # A simple script that outputs a small amount of data to STDOUT is
    # correctly passed through without modification.
    my ($base_stdout, $base_stderr, $base_exit) = Capture::Tiny::capture {
        system($EXECUTABLE_NAME, "$test_bin_dir/minimal-stdout.pl")
    };
    subtest(
        'Base program',
        sub {
            like(
                $base_stdout,
                qr/brillig .+ borogoves .+ have \s to \s do/xsm,
                'We get a bit of Jabberwocky to STDOUT'
            );
            is(ord(substr(Encode::decode('UTF8', $base_stdout), 0, 1)), 0x2019,
                'We got a Unicode right single quotation mark in the UTF8');
            is($base_stderr, '', 'Nothing spat out to STDERR');
            is($base_exit, 0, 'Ordinary exit code');
        }
    );

    my ($nosplurge_stdout, $nosplurge_stderr, $nosplurge_exit)
        = Capture::Tiny::capture {
        system(@nosplurge_incantation, "$test_bin_dir/minimal-stdout.pl");
        };
    subtest(
        'Base program via nosplurge',
        sub {
            is($nosplurge_stdout, $base_stdout,
                'Same STDOUT as the base program');
            is($nosplurge_stderr, '', 'Still nothing spat out to STDERR');
            is($nosplurge_exit,   0,  'Still an ordinary exit code');
        }
    );
}