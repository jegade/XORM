#!env perl

use Test::More; 

use XORM;

my $xorm = XORM->new( id => 99  ) ;


is($xorm->save,undef,"Done");

done_testing();




