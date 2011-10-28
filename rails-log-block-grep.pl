#!/usr/bin/perl
use strict;
use warnings;
use constant LENGTH => 256;
use Getopt::Long;

$| = 1;

print <<EOM;
!!! WARNING !!!

Sorry, this program is not maintained.
May disappear in the future.
Please use `rails-log-block-grep.rb' instead.

EOM
sleep 3;

GetOptions(
    '-A=i' => \my $after,
    '-B=i' => \my $before,
);

my (@after, @before);

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

        if ($before) {
            push @before, $block;
            shift @before if scalar @before > $before;
        }

        if ($block =~ /$pattern/o) {
            print @before if @before;
            print $block;
            print @after if @after;
        }

        if ($after) {
            push @after, $block;
            shift @after if scalar @after > $after;
        }

        undef $block;
    }
}
