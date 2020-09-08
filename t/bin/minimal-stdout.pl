#!/usr/bin/env perl
# A simple test script that spits out a small amount of text to STDOUT.
# It includes UTF8-encoded Unicode just to be sure.

use strict;
use warnings;
use utf8;
use Encode;

print Encode::encode('UTF8', <<JABBERWOCKY_INTRO);
’Twas brillig, and the slithy toves
Did gyre and gimble in the wabe.
All mimsy were the borogoves,
And the mome raths outgrade.

I can’t remember the next bit, so
This will have to do.
JABBERWOCKY_INTRO
