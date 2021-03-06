package GameOfLife;

our $VERSION = '0.1';

use strict;
use warnings;
use Data::Dumper;


=pod

=head1 НАЗВАНИЕ

GameOfLife - класс для реализации игры "Жизнь" (Conway's Game of Life)

=head1 ОПИСАНИЕ

Игра происходит на бесконечном двумерном клеточном поле
Таким образом, у каждой клетки есть 8 соседей
Каждая клетка может быть живой (1) или мёртвой (0)
Игрок задаёт только начальную позицию в виде 2D-массива нулей и единиц
Далее игра развивается самостоятельно. На каждом следующем шаге рассчитыватся
новое состояние всех клеток на основании текущей матрицы:
Живая клетка, у которой меньше двух живых соседей, умирает (от одиночества)
Живая клетка, у которой больше трёх живых соседей, умирает (от перенаселённости)
Живая клетка, у которой 2 или 3 соседа, остаётся живой.
В мёртвой клетке, у которой ровно 3 живых соседа, появляется жизнь.

=head1 ПРИМЕР

use GameOfLife;

# задаём начальную конфигурацию
# необязатльный параметр max_size - ограничение размера матрицы,
# по дефолту 100. чтобы избежать проблем с ресурсами на больших матрицах
my $game = new GameOfLife([
	[0,0,1],
	[1,0,1],
	[0,1,1]
], {max_size=>50});

# вычисляем следующее состояние поля
$game->iteration();

# текущий размер поля
my ($x,$y) = ($game->col_count(), $game->row_count());

# номер текущей итерации
my $num = $o->icount();

# ссылка на текущую матрицу (2D-массив)
my $m = $game->matrix();

# вернуть состояние элемента в строке $row и столбце $col (1 или 0)
# $row и $col могут указывать за границу текущей матрицы, 
# в том числе, быть отрицательными
my $val = $game->get($row, $col);

=cut




=head2 new

	Конструктор. На вход получает начальную матрицу (2D-массив)
	и, опционально, дополнительные параметры

=cut

sub new {
	my $c = shift;
	my $class = ref $c || $c;
	my $o = {};
	bless $o, $class;

	# начальная матрица - двумерный массив
	$o->{matrix} = shift;

	# счётчик итераций
	$o->{icount} = 0;

	# дополнительные параметры - ссылка на хэш
	my $args = shift;
	# лимит на размер матрицы
	$o->{max_size} = $args->{max_size}||100; 

	return $o;
}




=head2 matrix

	Возвращает текущую матрицу (ссылку на двумерный массив)

=cut

sub matrix {
	my $o = shift;
	return $o->{matrix};
}




=head2 icount

	Возвращает количество итераций

=cut

sub icount {
	my $o = shift;
	return $o->{icount};
}




=head2 row_count

	Возвращает текущее количество строк

=cut

sub row_count {
	my $o = shift;
	return scalar(@{$o->{matrix}});
}




=head2 col_count

	Аналогично для столбцов

=cut

sub col_count {
	my $o = shift;
	unless($o->row_count()){
		return 0;
	}
	return scalar(@{$o->{matrix}->[0]});
}




=head2 get

	Возвращает состояние клетки с указанными координатами (строка, столбец)

=cut

sub get {
	my ($o, $r, $c) = @_;
	# нужно учесть, что координаты могут указывать за границу текущей матрицы
	# к примеру, perl по индексу -1 вернёт последний элемент массива
	# а нам нужно чтобы возвращался 0 (дефолтное состояние всех клеток поля
	# за границами матрицы)
	if($r<0 || $c<0){
		return 0;
	}
	if($r > scalar(@{$o->{matrix}})-1){
		return 0;
	}
	return $o->{matrix}->[$r]->[$c]||0;
}




=head2 neighbors

	Возвращает количество живих соседей указанной клетки

=cut

sub neighbors {
	my ($o, $r, $c) = @_;
	return 
		$o->get($r-1, $c-1) + $o->get($r-1, $c) + $o->get($r-1, $c+1)
		+ $o->get($r, $c-1) + $o->get($r, $c+1)
		+ $o->get($r+1, $c-1) + $o->get($r+1, $c) + $o->get($r+1, $c+1)
	;
}




=head2 calc_cell

	Рассчитывает новое состояние клетки

=cut

sub calc_cell {
	my ($o, $r, $c) = @_;
	my $n = $o->neighbors($r, $c);
	if( $n==3 || ($n==2 && $o->get($r,$c)) ){
		return 1;
	}
	return 0;
}




=head2 sum_row

	Считает сумму элементов в строке

=cut

sub sum_row {

	# TODO что делать если массив пустой

	my $o = shift;
	my $r = shift;
	my $sum = 0;
	map {$sum += $_} @{$o->{matrix}->[$r]};
	return $sum;
}




=head2 sum_col

	Считает сумму элементов в столбце

=cut

sub sum_col {
	my $o = shift;
	my $c = shift;
	my $sum = 0;

	map {$sum += $_->[$c]} @{$o->{matrix}};
	return $sum;

}




=head2 trim

	Убирает по краям матрицы столбцы/строки, 
	в которых нет единиц

=cut

sub trim {
	my $o = shift;
	while ($o->row_count() && !$o->sum_row(0)){
		shift @{$o->{matrix}};
	}
	if(!$o->row_count()){
		# матрица полностью пустая
		return;
	}
	# если дошли сюда, в матрице точно есть ненулевые элементы
	# можно уже не проверять условие на $o->row_count()
	while (!$o->sum_row($o->row_count()-1)){
		pop @{$o->{matrix}};
	}
	while (!$o->sum_col(0)){
		foreach my $row (@{$o->{matrix}}){
			shift @$row;
		}
	}
	while (!$o->sum_col($o->col_count()-1)){
		foreach my $row (@{$o->{matrix}}){
			pop @$row;
		}
	}
}




=head2 create_matrix

	Создаёт новую матрицу заданных размеров, заполненную нулями
	возвращает ссылку на двумерный массив

=cut

sub create_matrix {
	my ($o, $r, $c) = @_;

	# тут нужно быть аккуратным, чтобы в строках не получились ссылки
	# на один и тот же массив
	# вот так красиво, но нельзя:
	# return [([(0) x $c]) x $r]

	my $result = [];
	for (1..$r){
		my @row = (0) x $c;
		push(@$result, \@row);
	}
	return $result;
}




=head2 iteration

	Осуществляет иттерацию, полностью обновляя матрицу

=cut

sub iteration {
	my $o = shift;

	$o->{icount}++;

	# создаём новую матрицу
	# она должна быть больше текущей на 1 с каждой стороны
	# (итого на 2 по каждому измерению)
	# т.к. в этих крайних строках и столбцах могут появиться живые клетки
	my $mtrx = $o->create_matrix($o->row_count()+2, $o->col_count()+2);

	# проходимся циклом по всем элементам новой матрицы,
	# рассчитываем новое состояние
	# нужно учесть, что индексы в новой матрице смещены на 1
	# относительно старой, из-за добавленных строк и столбцов
	for(my $r=0; $r<scalar(@$mtrx); $r++){
		for(my $c=0; $c<scalar(@{$mtrx->[$r]}); $c++){
			if($o->calc_cell($r-1,$c-1)){
				$mtrx->[$r]->[$c] = 1;
			}
		}
	}

	# заменяем матрицу на новую
	# сборщик мусора должен автоматом удалить старый массив
	$o->{matrix} = $mtrx;

	# удаляем по краям пустые строки/столбцы
	$o->trim();

	# проверяем размер
	if($o->row_count() > $o->{max_size}){
		die "Row count (".$o->row_count().") exeeds max size (".$o->{max_size}.")";
	}
	if($o->col_count() > $o->{max_size}){
		die "Col count (".$o->col_count().") exeeds max size (".$o->{max_size}.")";
	}

}


return 1;
