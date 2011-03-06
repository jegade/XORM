#!env perl

use Test::More; 



require_ok( 'XORM' );


my $xorm = XORM->new( id => 99  ) ;

isa_ok($xorm,'XORM');

done_testing();




