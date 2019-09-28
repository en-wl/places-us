use warnings;
use strict;

use sort 'stable';

use List::Util qw(any all);

use open IO => ':utf8', ':std';

my %d;

my %dict;
open DICT, "aspell dump master -d en_US |";
while (<DICT>) {
    chomp;
    push @{$dict{lc $_}}, $_;
    push @{$dict{$_}}, $_;
}

sub lookup_dict_single ($) {
    local $_ = $_[0];
    return 'Y' if $dict{$_};
    return 'y' if $dict{lc $_};
    return 'n';
}

sub combine (@) {
    return 'Y' if all {$_ eq 'Y'} @_;
    return 'y' if all {$_ eq 'Y' || $_ eq 'y'} @_;
    return 'p' if any {$_ eq 'Y' || $_ eq 'y'} @_;
    return 'n';
}

sub lookup_dict ($) {
    local $_ = $_[0];
    my $sp = lookup_dict_single $_;
    return $sp unless $sp eq 'n';
    my @parts = split /[^A-Za-z']+/;
    my @sp;
    foreach (@parts) {
        push @sp, lookup_dict_single $_;
    }
    return combine @sp;
}

while (<>) {
    chomp;
    my ($cat, $name, $state, $what, $pop) = split /\t/;
    die "$_" unless defined $name;
    $d{$cat}{"$name  $state"} = [$what, $pop];
}

my %seen;

sub lookup_place ($@) {
    my ($n, @l) = @_;
    my @res;
    foreach my $l (@l) {
        next unless exists $d{'place'}{"$n  $l"};
        next if exists $seen{"$n  $l"};
        my ($what, $pop) = @{$d{'place'}{"$n  $l"}};
        push @res, [$n,$l,$what,$pop];
    }
    if (@res == 0) {
        warn "no match for $n  @l";
        return ($n,'','',0, 'n');
    } elsif (@res > 1) {
        #warn "multiple matches for $n  @l";
        #foreach (@res) {
        #    warn "  ".join('  ', @$_)."\n";
        #}
    }
    my $max;
    foreach (@res) {
        $max = $_ unless defined $max && $max->[3] > $_->[3];
    }
    $seen{"$max->[0]  $max->[1]"}++;
    return @$max;
}

my @table;
push @table, ['Area Name', 'Place Name', 'Location', 'Place Pop', 'Area Pop', 'What', 'In Dict'];

foreach my $key (sort {$d{'ua'}{$b}[1] <=> $d{'ua'}{$a}[1]} keys %{$d{'ua'}}) {
    my ($what, $pop) = @{$d{'ua'}{$key}};
    my ($name,$loc) = $key =~ /^(.+)  (.+)$/ or die "?? $key";
    #next unless $what eq 'Urbanized Area';
    my @name = split ';', $name;
    my @loc  = split ';', $loc;
    my @d;
    my @sp;
    foreach my $n (@name) {
        my (undef,$l,$what,$pop_place) = lookup_place($n, @loc);
        next unless $pop_place > 0;
        my $sp = lookup_dict($n);
        push @d, ['', $n, $l, $pop_place, '', $what, $sp];
        push @sp, $sp;
    }
    push @table, [join('/',@name), '', join('/',@loc), '', $pop, $what, combine @sp];
    @d = sort {$b->[3] <=> $a->[3]} @d;
    push @table, @d;
}


push @table, ['','','','','',''];

foreach my $key (sort {$d{'place'}{$b}[1] <=> $d{'place'}{$a}[1]} keys %{$d{'place'}}) {
    my ($name,$loc) = $key =~ /^(.+)  (.+)$/ or die "?? $key";
    my ($what, $pop) = @{$d{'place'}{$key}};
    next unless $pop >= 1000;
    my $sp = lookup_dict($name);
    push @table, ['', $name, $loc, $pop, '', $what, $sp] unless $seen{$key};
    #push @table, ['(', $name, $loc, $pop, ')', $what, $sp] if $seen{$key};
}

#@d = sort {$b->[2] <=> $a->[2]} @d;
#foreach (@d) {print join('  ',@$_)."\n";}

foreach (@table) {
    print join("\t", @$_)."\n";
}

