#!env perl

package XORM::Set;

use Moose;
use Data::UUID;
use Array::Utils qw(:all);

has 'filter' => (

    isa     => 'HashRef',
    is      => 'rw',
    default => sub { {} },
);

has '_cursor' => (

    isa => 'MongoDB::Cursor',
    is  => 'rw',
);

has 'base' => (

    isa => 'Object',
    is  => 'rw',
);

has 'limit' => (
    isa     => 'Int',
    is      => 'rw',
    default => 10000,
);

has 'skip' => (
    isa     => 'Int',
    is      => 'rw',
    default => 0,
);

has 'sort_by' => (
    isa => 'Str',
    is  => 'rw',
);

=head2 all

=cut

sub all {

    my $self = shift;

    shift->cursor->all;
}

=head2 next

    Next item from iterator

=cut

sub next {

    my ($self) = @_;
    $self->base->objectify( $self->cursor->next );
}

=head2 reset 

    Reset Iterator

=cut

sub reset {

    shift->cursor->reset;
}

=head2 first

    First Item or undef

=cut

sub first {

    my ($self) = @_;
    $self->cursor->reset;
    $self->base->objectify( $self->cursor->next );

}

=head2 cursor


=cut

sub cursor {

    my $self = shift;

    if ( !$self->_cursor ) {
        $self->_cursor( $self->rs );
    }

    return $self->_cursor;
}

=head2 reset_filter

=cut

sub reset_filter {

    my $self = shift;
    $self->filter( {} );
    $self->cursor(undef);

    return $self;
}

sub add_filter {

    my ( $self, $add_filter ) = @_;


    $self->cursor(undef);    # Reset Cursor
    $self->filter( { %{ $self->filter }, %$add_filter } );

    return $self;
}

=head2 rs

=cut

sub rs {

    my $self = shift;
    
    use Data::Dumper;
    warn Dumper( $self->filter ) ; 
    $self->base->collection->query( $self->filter, { limit => $self->limit, skip => $self->skip, sort_by => $self->sort_by } );
}

1;
