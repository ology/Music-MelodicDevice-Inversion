#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

use_ok 'Music::MelodicDevice::Inversion';

my $obj = new_ok 'Music::MelodicDevice::Inversion';

# https://music.stackexchange.com/questions/32507/what-is-melodic-inversion-and-how-to-do-it/
my $notes = [qw(A4 C5 B4 A4 E5)];
my $expect = [qw(3 -1 -2 7)];
my $got = $obj->intervals($notes);
is_deeply $got, $expect, 'intervals';
$expect = ['E5','C#5','D5','E5','A4'];
$got = $obj->invert('E5', $notes);
is_deeply $got, $expect, 'invert';

$notes = [qw(C4 E4 D4 G4 C5)];
$expect = [qw(4 -2 5 5)];
$got = $obj->intervals($notes);
is_deeply $got, $expect, 'intervals';
$expect = ['C4','G#3','A#3','F3','C3'];
$got = $obj->invert('C4', $notes);
is_deeply $got, $expect, 'invert';

$obj = new_ok 'Music::MelodicDevice::Inversion' => [
    scale_name => 'major',
#    verbose => 1,
];
$expect = [qw(2 -1 3 3)];
$got = $obj->intervals($notes);
is_deeply $got, $expect, 'intervals';
$expect = [qw(C4 A3 B3 F3 C3)];
$got = $obj->invert('C4', $notes);
is_deeply $got, $expect, 'invert';

# https://en.wikipedia.org/wiki/Inversion_(music)#Melodies
$notes = [qw(G4 A4 G4 F4 G4 A4 B4 A4 G4 A4)];
$expect = [qw(1 -1 -1 1 1 1 -1 -1 1)];
$got = $obj->intervals($notes);
is_deeply $got, $expect, 'intervals';
$expect = [qw(D3 C3 D3 E3 D3 C3 B2 C3 D3 C3)];
$got = $obj->invert('D3', $notes);
is_deeply $got, $expect, 'invert';

done_testing();
