/* NetWalk game code
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
#include <stdlib.h>
#include <string.h>
#include "game.h"

//tile = integer
//bits 0...3 specify which directions lead out
//bit 4 = connected
//bit 5 = server
int boardw = 10, boardh = 9;
int board[boardmaxw][boardmaxh];
int neighbourcount[boardmaxw][boardmaxh];
int flags[boardmaxw][boardmaxh];
int sourcex, sourceytop, sourceybottom;

int wrap_flag = 0;
int no_fourway = 0;
int game_won = 0;

static int par;

coord_s dir[4] = {
    {0, -1},
    {1, 0},
    {0, 1},
    {-1, 0},
};
// 0 = up, 1 = right, 2 = down, 3 = left
//    0
//    |
// 3--+--1
//    |
//    2

void add_dir(int *x, int *y, int x1, int y1, int d)
{
    *x = x1 + dir[d].x;
    *y = y1 + dir[d].y;

    if (wrap_flag) {
	if (*x < 0) *x = boardw - 1;
	if (*x >= boardw) *x = 0;
	if (*y < 0) *y = boardh - 1;
	if (*y >= boardh) *y = 0;
    }
}

void clear_flags()
{
	int i;
	for(i = 0;i < boardw;i++)
	{
		int j;
		for(j = 0;j < boardh;j++)
			flags[i][j] = 0;
	}
}

void generate_maze()
{
    coord_s opentile[boardmaxw * boardmaxh];
    int n;
    int i, j;
    int x, y;
    int x1, y1;

    n = 2;
    opentile[0].x = sourcex;
    opentile[1].x = sourcex;
    opentile[0].y = sourceytop;
    opentile[1].y = sourceybottom;

    for (i=0; i<boardw; i++) {
	for (j=0; j<boardh; j++) {
	    board[i][j] = 0;
	    neighbourcount[i][j] = 0;
	}
    }
    board[sourcex][sourceytop] = 32;
    board[sourcex][sourceybottom] = 32;

    while (n) {
	int flag;

	i = rand() % n;
	x = opentile[i].x;
	y = opentile[i].y;

	//check if surrounded
	flag = 1;

	//special case for top of server
	if (x == sourcex && y == sourceytop) {
	    if (!board[x][y-1]) {
		flag = 0;
	    }
	    //don't need special case for bottom of server
	    //top is blocked by top server
	} else {
	    for (j=0; j<4; j++) {
		add_dir(&x1, &y1, x, y, j);
		if (x1 < 0 || x1 >= boardw
			|| y1 < 0 || y1 >= boardh) {
		    continue;
		}

		if (!board[x1][y1]) {
		    flag = 0;
		    break;
		}
	    }
	}
	
	//if so, remove from list
	if (flag) {
	    n--;
	    memmove(&opentile[i], &opentile[i+1], sizeof(coord_s) * (n - i));
	    continue;
	}

	j = rand() % 4;

	//not allowed left or right from top of server
	if (x == sourcex && y == sourceytop) {
	    if (j % 2) continue;
	}

	add_dir(&x1, &y1, x, y, j);

	if (x1 < 0 || x1 >= boardw
		|| y1 < 0 || y1 >= boardh) continue;
	if (board[x1][y1]) continue;
	if (no_fourway && neighbourcount[x][y] >= 3) continue;
	neighbourcount[x][y]++;
	neighbourcount[x1][y1]++;

	board[x][y] |= (1 << j);
	board[x1][y1] |= (1 << ((j + 2) % 4));

	opentile[n].x = x1;
	opentile[n].y = y1;
	n++;
    }
}

int rotatecw(int d, int n)
{
    int i;
    int d1;

    d1 = d;
    for (i=0; i<n; i++) {
	d1 = (d1 << 1);
	if (d1 >= 16) d1 -= 15;
    }
    return d1;
}

void scramble()
{
    int i, j;
    int d, d1;

    par = 0;

    game_won = 0;

    //handle server by temporarily merging the two blocks into one

    board[sourcex][sourceybottom] |= board[sourcex][sourceytop] & 1;

    for (i=0; i<boardw; i++) {
	for (j=0; j<boardh; j++) {
	    if (i == sourcex && j == sourceytop) continue;
	    if (board[i][j]) {
		d = board[i][j] & 15;
		switch (rand() % 4) {
		    case 1:
			d1 = rotatecw(d, 1);
			if (d != d1) par++;
			break;
		    case 2:
			d1 = rotatecw(d, 2);
			if (d != d1) par+=2;
			break;
		    case 3:
			d1 = rotatecw(d, 3);
			if (d != d1) par++;
			break;
		    default:
			d1 = d;
			break;
		}

		board[i][j] &= ~15;
		board[i][j] += d1;
	    }
	}
    }

    board[sourcex][sourceytop] &= ~1;
    board[sourcex][sourceytop] |= board[sourcex][sourceybottom] & 1;
    board[sourcex][sourceybottom] &= ~1;
}

void check_live()
{
    coord_s opentile[boardmaxw * boardmaxh];
    int n;
    int i, j;
    int x, y;
    int x1, y1;
    int tilecount = 0;
    int livecount;

    n = 2;
    opentile[0].x = sourcex;
    opentile[1].x = sourcex;
    opentile[0].y = sourceytop;
    opentile[1].y = sourceybottom;

    for (i=0; i<boardw; i++) {
	for (j=0; j<boardh; j++) {
	    if (board[i][j]) tilecount++;
	    board[i][j] &= ~16;
	}
    }
    board[sourcex][sourceytop] |= 16;
    board[sourcex][sourceybottom] |= 16;
    livecount = 2;

    while (n) {
	n--;
	x = opentile[n].x;
	y = opentile[n].y;

	for (j=0; j<4; j++) {
	    if (board[x][y] & (1 << j)) {
		add_dir(&x1, &y1, x, y, j);
		if (x1 < 0 || x1 >= boardw
			|| y1 < 0 || y1 >= boardh) {
		    continue;
		}

		i = board[x1][y1];
		if (i & (1 << ((j + 2) % 4))) {
		    if (!(i & 16)) {
			board[x1][y1] |= 16;
			livecount++;
			opentile[n].x = x1;
			opentile[n].y = y1;
			n++;
		    }
		}
	    }
	}
    }
    if (livecount == tilecount) {
	game_won = 1;
    }
}
