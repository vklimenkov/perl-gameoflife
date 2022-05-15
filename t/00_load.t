=post
	тестируем загрузку GameOfLife
=cut

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/..";

plan tests => 1;

BEGIN {
	use_ok( 'GameOfLife' ) || print "Load error\n";
}
