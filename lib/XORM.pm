#!env perl

use MongoDB;
use MongoDB::OID;

package XORM;

use Moose;
use MooseX::Storage;

with Storage;

has 'id' => (

    isa      => 'Int',
    is       => 'rw',
    required => 0,
);

=head2 create

    Create an new Object

=cut

sub create {

    my ( $self, $attr ) = @_;

    $self->save;

}

=head2 save

    Save a object to the database, required after any modification

=cut

sub save {

    my ($self)     = @_;
    my $collection = $self->_collection;
    my $packed     = $self->pack;

    use Data::Dumper;

    warn Dumper($packed);

    $self->_storage->$collection->update( { id => $self->id }, $packed, { "upsert" => 1, "multiple" => 0 } );
    return;
}

=head2 update

    update

=cut 

sub update {

    my ( $self, $attr ) = @_;

    $self->save;
}

=head2 delete


=cut

sub delete {

    my $self = shift;

    my $collection = $self->_collection;
    $self->_storage->$collection->remove( { id => $self->id } );

}

sub _storage {

    return MongoDB::Connection->new->xorm;
}

sub _collection {

    my ($self) = @_;
    my $name = $self->meta->name;
    $name =~ s/\W+/_/g;
    return lc($name);
}

1;
