#! env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

package Model::Person;

use Email::Valid;
use Moose;
use Moose::Util::TypeConstraints;

extends 'XORM';

subtype 'Email' => as 'Str' => where { Email::Valid->address($_) } => message { "$_ ist not a valid email address" };

has 'firstname' => ( isa => 'Str',   is => 'rw' );
has 'lastname'  => ( isa => 'Str',   is => 'rw' );
has 'email'     => ( isa => 'Email', is => 'rw', required => 1 );

package Model::Event;

use Moose;
use DateTime;

extends 'XORM';

has 'name' => ( isa => 'Str', is => 'rw' );
has 'date' => ( isa => 'Int', is => 'rw', default => sub { DateTime->epoch } );

has '_members' => ( isa => 'ArrayRef[Str]', is => 'rw' );

sub members {

    my ($self) = @_;
    return $self->_related('members');
}

sub add_member {

    my ( $self, $member ) = @_;

    $self->_add_related( 'members', $member );

    return;

}

sub delete_member {

    my ( $self, $member ) = @_;

    $self->_delete_related( 'members', $member );

    return;

}

sub set_members {

    my ( $self, $members ) = @_;

    $self->_set_related( 'members', $members );

    return;

}

package main;

my $person = Model::Person->new( email => 'jens@atomix.de' );

$person->save;

my $event = Model::Event->new( date => 1000000 );

$event->set_members( [ $person, $person ] );

$event->save;


my $itr = $event->members;

while ( my $member = $itr->next ) {

    print $member->email."\n";
}

