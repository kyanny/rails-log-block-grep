#!/usr/bin/perl
use strict;
use warnings;
use constant LENGTH => 256;
use Pod::Usage;

$| = 1;

my $pattern = shift || pod2usage(2);
my $buf;
my $buffer;

while (read(STDIN, $buf, LENGTH)) {
    $buffer .= $buf;
    if ($buffer =~ /^(
                     Processing.*?(?=Processing)
                     |
                     Sent\smail:.*?(?=Sent\smail:)
                     )
                   /msox) {
        my $block = $&;
        undef $buffer;
        if ($block =~ /$pattern/o) {
            print $block;
        }
        undef $block;
    }
}
