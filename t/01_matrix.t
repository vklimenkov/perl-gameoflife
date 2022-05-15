=post
	тестируем функционал GameOfLife, связанный с работой с матрицами
=cut

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/..";
use GameOfLife;


plan tests => 19;


my $game = new GameOfLife([
	[0,0,0,1,0],
	[0,0,0,0,1],
	[1,0,0,0,1],
	[0,1,1,1,1],
]);


ok($game->col_count() == 5, "col count");
ok($game->row_count() == 4, "row count");

ok($game->get(0,0) == 0, "0 element");
ok($game->get(3,2) == 1, "1 element");

ok($game->get(-1,2) == 0, "out of range element - 1");
ok($game->get(5,2) == 0, "out of range element - 2");
ok($game->get(0,-2) == 0, "out of range element - 3");
ok($game->get(0,8) == 0, "out of range element - 4");

ok($game->neighbors(0,0) == 0, "neighbors - 1");
ok($game->neighbors(-1,2) == 1, "neighbors - 2");
ok($game->neighbors(4,2) == 3, "neighbors - 3");
ok($game->neighbors(2,3) == 5, "neighbors - 4");
ok($game->neighbors(3,4) == 2, "neighbors - 5");

ok($game->sum_row(0) == 1, "sum_row - 1");
ok($game->sum_row(3) == 4, "sum_row - 2");

ok($game->sum_col(0) == 1, "sum_col - 1");
ok($game->sum_col(3) == 2, "sum_col - 2");


my $mtrx = $game->create_matrix(5,6);
ok(check_matrix($mtrx,5,6, 0), "create matrix");

$mtrx->[2]->[2] = 1;
my $game2 = new GameOfLife($mtrx);
$game2->trim();
ok(check_matrix($game2->matrix(),1,1,1), "trim matrix");





sub check_matrix {
	my ($m, $rows, $cols, $val) = @_;

	# проверяем, что размер корректный, строки одинаковой длины 
	# и все элементы defined и равны val, если val задана

	if(scalar(@$m)!=$rows){
		return 0;
	}

	for(my $r = 0; $r<$rows; $r++){
		unless($m->[$r]){
			return 0;
		}
		if(scalar(@{$m->[$r]})!=$cols){
			return 0;
		}
		for(my $c = 0; $c<$cols; $c++){
			if(!defined $m->[$r]->[$c]){
				return 0;
			}
			if(defined $val && $m->[$r]->[$c] != $val){
				return 0;
			}
		}
	}

	return 1;
}


