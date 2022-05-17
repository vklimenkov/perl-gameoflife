=post
	тестируем непосредственно алгоритм игры GameOfLife
	конечно, текущий тест охватывает не все ситуации и будет дополняться
=cut

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/..";
use GameOfLife;


plan tests => 5;

# создаём одну из простейших конфигураций - "мигалка"
# это горизонтальная палочка из трёх единичных элементов
# такая конфигурация циклически переходит в вертикальную, 
# а потом снова в изначальное состояние
my $game = new GameOfLife([
	[1,1,1]
]);

# заодно проверим работу счётчка итераций
ok($game->icount() == 0, "iteration count - 0");

$game->iteration();
ok(compare_matrices($game->matrix(), [[1],[1],[1]]), "iteration 1");
ok($game->icount() == 1, "iteration count - 1");

$game->iteration();
ok(compare_matrices($game->matrix(), [[1,1,1]]), "iteration 2");
ok($game->icount() == 2, "iteration count - 2");





sub compare_matrices {
	my ($m1, $m2) = @_;

	# матрицы должны быть полностью одинаковые:
	# все размеры и значения элементов

	if(scalar(@$m1) != scalar(@$m2)){
		return 0;
	}

	for(my $r = 0; $r<scalar(@$m1); $r++){
		unless($m1->[$r] && $m2->[$r]){
			return 0;
		}
		if(scalar(@{$m1->[$r]})!=scalar(@{$m2->[$r]})){
			return 0;
		}
		for(my $c = 0; $c<scalar(@{$m1->[$r]}); $c++){
			if(!defined $m1->[$r]->[$c] || ! defined $m2->[$r]->[$c]){
				return 0;
			}
			if($m1->[$r]->[$c] != $m2->[$r]->[$c]){
				return 0;
			}
		}
	}

	return 1;
}


