/*
 * Ben Lynn
 */
/*
Copyright (C) 2004 Benjamin Lynn (blynn@cs.stanford.edu)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/
#ifndef GAME_H
#define GAME_H

enum {
    boardmaxw = 50,
    boardmaxh = 50,
};
extern int boardw, boardh;
extern int board[boardmaxw][boardmaxh];
extern int neighbourcount[boardmaxw][boardmaxh];
extern int flags[boardmaxw][boardmaxh];
extern int sourcex, sourceytop, sourceybottom;
extern int wrap_flag;
extern int no_fourway;
extern int game_won;

typedef struct {
    int x, y;
} coord_s;

extern coord_s dir[4];

// 0 = up, 1 = right, 2 = down, 3 = left
//    0
//    |
// 3--+--1
//    |
//    2

void clear_flags();
void generate_maze();
int rotatecw(int d, int n);
void scramble();
void check_live();
void add_dir(int *x, int *y, int x1, int y1, int d);
#endif //GAME_H
