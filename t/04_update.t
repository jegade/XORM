#!env perl

use Test::More; 

use XORM;

my $xorm = XORM->new( id => 99  ) ;

$xorm->update( { id => 999999 });

is($xorm->id,99,"updated");

done_testing();




