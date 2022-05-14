#!/usr/bin/perl

=post
	пример скрипта, иллюстрирующего работу модуля GameOfLife
=cut

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

use Data::Dumper;
use Term::Screen::Uni;

use FindBin qw($Bin);
use lib "$Bin";
use GameOfLife;



# мигалка:
# my $game = new GameOfLife([[1,1,1]]);

# планер:
# my $game = new GameOfLife([[0,0,1],[1,0,1],[0,1,1]]);

# космический корабль:
my $game = new GameOfLife([
	[0,0,0,1,0],
	[0,0,0,0,1],
	[1,0,0,0,1],
	[0,1,1,1,1],
]);


my $scr = new Term::Screen::Uni;

while (1){
	$scr->clrscr();
	$scr->at(0,0)->puts(
		"Iteration: ".$game->icount()
		.", matrix size: ".$game->col_count()." x ".$game->row_count()
	);
	print_matrix($game->matrix());
	$game->iteration();
	if(!$game->row_count()){
		die "Matrix is empty";
	}
	sleep 1;
}


sub print_matrix {
	my $m = shift;
	for(my $r=0; $r<scalar(@$m); $r++){
		for(my $c=0; $c<scalar(@{$m->[$r]}); $c++){
			$scr->at($r+2,$c*2)->puts($m->[$r]->[$c] ? "\x{25a0}": "\x{25a1}");
		}
	}
}
