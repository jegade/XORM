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

subtype 'Email'
    => as 'Str'
    => where { Email::Valid->address($_) }
    => message { "$_ ist not a valid email address" };
    

has 'firstname' => ( isa => 'Str', is => 'rw' ) ;
has 'lastname'  => ( isa => 'Str', is => 'rw' ) ;
has 'email'     => ( isa => 'Email', is => 'rw', required => 1 );


package main;


my $person = Model::Person->new( email => 'jens@atomix.de' );

$person->save;

