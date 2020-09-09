#!/usr/bin/env perl
# A simple script that spits out a mixture of stuff to STDOUT and STDERR.

use strict;
use warnings;
use Time::HiRes;

STDOUT->autoflush(1);
STDERR->autoflush(1);

my @lines = split(/\n/, <<DUET_LYRICS);
I can jump a hurdle
I can wear a girdle
I can knit a sweater
I can fill it better
I can do most anything
Can you bake a pie?
No
Neither can I
DUET_LYRICS

while (my ($stdout_line, $stderr_line) = splice(@lines, 0, 2)) {
    print STDOUT $stdout_line, "\n";
    Time::HiRes::sleep(0.02);
    print STDERR $stderr_line, "\n";
    Time::HiRes::sleep(0.03);
}
