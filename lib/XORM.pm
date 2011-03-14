#!env perl

use MongoDB;
use MongoDB::OID;

package XORM;

use Moose;
use MooseX::Storage;
use Data::UUID;
use Array::Utils qw(:all);

use XORM::Set;

use Data::Model::Iterator;

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
    my $packed     = $self->pack;

    use Data::Dumper;

    warn Dumper($packed);

    $self->collection->update( { id => $self->id }, $packed, { "upsert" => 1, "multiple" => 0 } );
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
    $self->collection->remove( { id => $self->id } );

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

sub collection {

    my $self = shift;
    my $collection = $self->_collection;
    return $self->_storage->$collection;
}

sub _to_class {

    my ( $self, $class, $doc ) = @_;
    return $class->unpack($doc);

}

sub _add_related {

    my ( $self, $relation, $class, $obj ) = @_;
    $relation = "_" . $relation unless $relation =~ /^_/;
    my $id = [ ref $obj ? $obj->id : $obj ];
    my $objs = [ unique( @{ $self->$relation }, @$id ) ];
    $self->_set_related( $relation, $class, $objs );
    return 1;
}

sub _delete_related {

    my ( $self, $relation, $class, $obj ) = @_;
    $relation = "_" . $relation unless $relation =~ /^_/;
    my $id = [ ref $obj ? $obj->id : $obj ];
    my $objs = [ array_minus( @{ $self->$relation }, @$id ) ];
    $self->_set_related( $relation, $class,  $objs );
    return 1;
}

sub _set_related {

    my ( $self, $relation, $class, $objs ) = @_;
    $relation = "_" . $relation unless $relation =~ /^_/;
    my $ids = [ map { ref $_ ? $_->id : $_ } @$objs ];
    $self->$relation($ids);
    return 1;
}

sub _related {

    my ( $self, $relation, $class ) = @_;
    $relation = "_" . $relation unless $relation =~ /^_/;
    my $objs = $self->$relation;
    return $self->_set( $class )->add_filter( { id => $objs } );
}

sub objectify {
    
    my ( $self, $doc ) = @_;

    my $class = $doc->{__CLASS__};
    return $class->unpack($doc);
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

sub _set_name {

    my ( $self, $gclass  ) = @_;
    return ( $gclass || ref $self)."::Set";
}

sub _set {

    my ( $self, $gclass ) = @_;

    my $class = $self->_set_name( $gclass );
    eval "use $class;";
    
    if ( $@ ) {

        eval "package $class; use Moose; extends 'XORM::Set'; 1;";
        eval "use $class;" ;
    }

    return $class->new( base => $self );
}


1;
