#! env perl


use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use XORM;

my $n = XORM->new( id => 9999 );

$n->save;




