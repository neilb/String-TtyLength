#!perl
use strict;
use warnings;
use String::TtyLength qw/ tty_width /;
use Test2::V0;
use utf8;

my @TESTS = (
    ["word",                        [4],    "regular string"],
    ["café",                        [4],    "non-wide unicode character"],
    ["😄",                          [1,2],  "double-width emoji"],
    ["こんにちは",                  [5,10], "hiragana"],
    ["\e[32mこんにちは\e[0m",       [5,10], "red hiragana"],
);

foreach my $test (@TESTS) {
    my ($string, $widthsref, $label) = @$test;
    my $width = tty_width($string);

    ok(grep({ $_ == $width } @$widthsref), $label);
}

done_testing();
