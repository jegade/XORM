#!env perl

use MongoDB;
use MongoDB::OID;

package XORM;

use Moose;
use MooseX::Storage;
use Data::UUID;
use Array::Utils qw(:all);

with Storage;

has 'id' => (

    isa      => 'Str',
    is       => 'rw',
    required => 1,
    default  => sub { Data::UUID->new->create_str },
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

=head2 private

    interal stuff

=cut

sub _storage {

    return MongoDB::Connection->new->xorm;
}

sub _collection {

    my ($self) = @_;
    return "objects";
}

sub _to_class {

    my ( $self, $class, $doc ) = @_;
    return $class->unpack($doc);

}

sub _add_related {

    my ( $self, $relation, $obj ) = @_;
    $relation = "_" . $relation;
    my $id = [ ref $obj ? $obj->id : $obj ];
    my $objs = [ unique( @{ $self->relation }, @$id ) ];
    $self->_set_related( $relation, $objs );
    return 1;
}

sub _delete_related {

    my ( $self, $relation, $obj ) = @_;
    $relation = "_" . $relation;
    my $id = [ ref $obj ? $obj->id : $obj ];
    my $objs = [ array_minus( @{ $self->relation }, @$id ) ];
    $self->_set_related( $relation, $objs );
    return 1;
}

sub _set_related {

    my ( $self, $relation, $objs ) = @_;
    $relation = "_" . $relation;
    my $ids = [ map { ref $_ ? $_->id : $_ } @$objs ];
    $self->$relation($ids);
    return 1;
}

sub _related {

    my ( $self, $relation ) = @_;
    $relation = "_" . $relation;
    my $objs = $self->$relation;
    return [ map { $self->_get_from_storage($_) } @$objs ];

}

sub _get_from_storage {

    my ( $self, $id ) = @_;

    my $collection = $self->_collection;

    my $doc = $self->_storage->$collection->find_one( { id => $id } );

    if ($doc) {
        
        my $class = $doc->{__CLASS__};
        return $class->unpack($doc);
    } else {

        return;
    }

}

1;
