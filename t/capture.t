#!/usr/bin/env perl

use strict;
use warnings;

use lib::abs;
use Capture::Tiny;
use English qw(-no_match_vars);
use Test::More;

use App::Term::NoSplurge;

my $bin_dir = lib::abs::path('./bin');

subtest('Basic functionality', \&test_basics);
done_testing();

sub test_basics {
    # A simple script that outputs a small amount of data to STDOUT is
    # correctly passed through without modification.
    my ($base_stdout, $base_stderr, $base_exit) = Capture::Tiny::capture {
        system("$EXECUTABLE_NAME $bin_dir/minimal-stdout.pl")
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
}