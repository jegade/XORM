#!env perl

use Test::More; 

use XORM;

my $xorm = XORM->new( id => 99  ) ;

ok($xorm->delete, "delete");

done_testing();




