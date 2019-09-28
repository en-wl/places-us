use strict;
use warnings;

my $c = 0;
my @stats;

print join("\t", 'Pop', 'Y', 'y', 'p'), "\n";

#my @bands = (1000000,100000,50000,10000,5000,2500,1000);

my $width = 20;

<>;
while (<>) {
    chomp;
    my ($name, undef, $loc, undef, $pop, $what, $sp) = split "\t";
    next unless $name;
    #next unless $name =~ /^[A-Za-z']+$/;
    $c++;
    $stats[int($c/$width)]{max} = $pop unless defined $stats[int($c/$width)];
    $stats[int($c/$width)]{$sp}++;
    #my @accum = (0,0,0);
    #$accum[0] = $stats{Y};
    #$accum[1] = $accum[0] + $stats{y};
    #$accum[2] = $accum[1] + $stats{p};
    #print join("\t", $pop, $accum[0]/$c, $accum[1]/$c, $accum[2]/$c),"\n";
}

no warnings 'uninitialized';

foreach (@stats) {
    print join("\t", $_->{max}, $_->{Y}/$width, ($_->{y})/$width, ($_->{p})/$width)."\n";
}
