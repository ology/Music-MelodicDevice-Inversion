#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

use_ok 'Music::MelodicDevice::Inversion';

my @notes = qw(C4 E4 D4 G4 C5);

my $obj = new_ok 'Music::MelodicDevice::Inversion';
my $expect = [qw(4 -2 5 5)];
my $got = $obj->intervals(\@notes);
is_deeply $got, $expect, 'intervals';

$obj = new_ok 'Music::MelodicDevice::Inversion' => [
    scale_name => 'major',
    verbose => 1,
];
$expect = [qw(2 -1 3 3)];
$got = $obj->intervals(\@notes);
is_deeply $got, $expect, 'intervals';

done_testing();
