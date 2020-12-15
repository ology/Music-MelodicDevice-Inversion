package Music::MelodicDevice::Inversion;

# ABSTRACT: Apply melodic inversion to a series of notes

our $VERSION = '0.0100';

use Data::Dumper::Compact qw(ddc);
use List::SomeUtils qw(first_index uniq);
use Music::Scales qw(get_scale_notes);
use Music::Note;
use Moo;
use strictures 2;
use namespace::clean;

=head1 SYNOPSIS

  use Music::MelodicDevice::Inversion;

  my @notes = qw(C4 E4 D4 G4 C5);

  my $md = Music::MelodicDevice::Inversion->new(scale_name => 'major');
  my $intervals = $md->intervals(\@notes); # [2, -1, 3, 3]
  my $inv = $md->invert('C4', \@notes); # [C4, A3, B3, F3, C3]

  $md = Music::MelodicDevice::Inversion->new(scale_name => 'chromatic');
  $intervals = $md->intervals(\@notes); # [4, -2, 5, 5]
  $inv = $md->invert('C4', \@notes); # [C4, G#3, A#3, F3, C3]

=head1 DESCRIPTION

C<Music::MelodicDevice::Inversion> applies intervallic melodic
inversions, both chromatic or diatonic, to a series of notes, starting
at a given note.

While there are a couple modules on CPAN that do various versions of
melodic inversion, none appear to apply to an arbitrary series of
notes.  Hence this module.

=head1 ATTRIBUTES

=head2 scale_note

Default: C<C>

=cut

has scale_note => (
    is      => 'ro',
    isa     => sub { die "$_[0] is not a valid note" unless $_[0] =~ /^[A-G][#b]?$/ },
    default => sub { 'C' },
);

=head2 scale_name

Default: C<chromatic>

=cut

has scale_name => (
    is      => 'ro',
    isa     => sub { die "$_[0] is not a valid string" unless $_[0] =~ /^\w+$/ },
    default => sub { 'chromatic' },
);

has _scale => (
    is        => 'lazy',
    init_args => undef,
);

sub _build__scale {
    my ($self) = @_;

    my @scale = get_scale_notes($self->scale_note, $self->scale_name);
    print 'Scale: ', ddc(\@scale) if $self->verbose;

    my @scale_octaves = map { my $o = $_; map { $_ . $o } @scale } -1 .. 9;
    print 'Scale octaves: ', ddc(\@scale_octaves) if $self->verbose;

    return \@scale_octaves;
}

=head2 verbose

Default: C<0>

=cut

has verbose => (
    is      => 'ro',
    isa     => sub { die "$_[0] is not a valid boolean" unless $_[0] =~ /^[01]$/ },
    default => sub { 0 },
);

=head1 METHODS

=head2 new

  $md = Music::MelodicDevice::Inversion->new(scale_name => $scale);

Create a new C<Music::MelodicDevice::Inversion> object.

=head2 intervals

  $intervals = $md->intervals($notes);

=cut

sub intervals {
    my ($self, $notes) = @_;

    my @intervals;

    if ($self->scale_name eq 'chromatic') {
        my $pitches = $notes->[0] =~ /^\d+$/
            ? $notes
            : [ map { Music::Note->new($_, 'ISO')->format('midinum') } @$notes ];
        print 'Pitches: ', ddc($pitches) if $self->verbose;

        my $last;

        for my $pitch (@$pitches) {
            if (defined $last) {
                push @intervals, $pitch - $last;
            }
            $last = $pitch;
        }
    }
    else {
        my @indices;

        for my $note (@$notes) {
            push @indices, first_index { $_ eq $note } @{ $self->_scale };
        }
        print 'Indices: ', ddc(\@indices) if $self->verbose;

        my @diffs;

        my $last;

        for my $i (@indices) {
            if (defined $last) {
                push @diffs, $i - $last;
            }
            $last = $i;
        }

        @intervals = @diffs;
    }

    print 'Intervals: ', ddc(\@intervals) if $self->verbose;
    return \@intervals;
}

=head2 invert

  $inverted = $md->invert($note, $notes);

=cut

sub invert {
    my ($self, $note, $notes) = @_;
    my @inverted = ($note);
    my $intervals = $self->intervals($notes);
    my @scale_octaves = @{ $self->_scale };
    for my $interval (@$intervals) {
        my $x = $scale_octaves[ (first_index { $_ eq $note } @scale_octaves) - $interval ];
        push @inverted, $x;
        $note = $x;
    }
    print 'Inverted: ', ddc(\@inverted) if $self->verbose;
    return \@inverted;
}

1;
__END__

=head1 SEE ALSO

L<Music::AtonalUtil> (contains an "invert" method)

L<MIDI::Praxis::Variation> (contains an "inversion" function)

L<Moo>

L<Music::Note>

L<https://en.wikipedia.org/wiki/Inversion_(music)#Melodies>

L<https://music.stackexchange.com/a/32508/6683>

=cut
