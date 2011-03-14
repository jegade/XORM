#! env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

package Model::Person;

use XORM;
use Email::Valid;
use Moose;
use Moose::Util::TypeConstraints;

extends 'XORM';

subtype 'Email' => as 'Str' => where { Email::Valid->address($_) } => message { "$_ ist not a valid email address" };

has 'firstname' => ( isa => 'Str',   is => 'rw' );
has 'lastname'  => ( isa => 'Str',   is => 'rw' );
has 'email'     => ( isa => 'Email', is => 'rw', required => 1 );

1;

package Model::Person::Set;

use Moose;

extends 'XORM::Set';


1;

package Model::Event;

use Moose;
use DateTime;

extends 'XORM';

has 'name' => ( isa => 'Str', is => 'rw' );
has 'date' => ( isa => 'Int', is => 'rw', default => sub { DateTime->epoch } );

has '_members' => ( isa => 'ArrayRef[Str]', is => 'rw', default => sub { return [] } );

sub members {

    my ($self) = @_;
    return $self->_related( '_members', 'Model::Person' );
}

sub add_member {

    my ( $self, $member ) = @_;

    $self->_add_related( '_members', 'Model::Person', $member );

    return;

}

sub delete_member {

    my ( $self, $member ) = @_;

    $self->_delete_related( '_members', 'Model::Person', $member );

    return;

}

sub set_members {

    my ( $self, $members ) = @_;

    $self->_set_related( '_members', 'Model::Person', $members );

    return;

}

1;

package Model::Event::Set;

use Moose;

extends 'XORM::Set';

1;

package main;

my $person1 = Model::Person->new( email => 'jens@atomix.de' );

$person1->save;

my $person2 = Model::Person->new( email => 'master@atomix.de' );

$person2->save;

my $event = Model::Event->new( date => 1000000 );

$event->add_member($person1);
$event->add_member($person2);

$event->save;

my $itr = $event->members;

while ( my $member = $itr->next ) {

    use Data::Dumper;
    warn Dumper $member;

    print $member->email . "\n";
}

