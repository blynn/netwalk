/* Sets the colour scheme
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
#include "colour.h"

SDL_Color rgbtable[c_max];
int ctable[c_max];

void init_rgb(int c, int r, int g, int b)
{
    rgbtable[c].r = r;
    rgbtable[c].g = g;
    rgbtable[c].b = b;
}

void init_rgbtable()
{
    init_rgb(c_background, 50, 150, 50);
    init_rgb(c_menubg, 0, 50, 0);
    init_rgb(c_shadow, 20, 100, 20);
    init_rgb(c_darkshadow, 0, 0, 0);
    /* border highlight for cell that the mouse is pointing at */
    init_rgb(c_highlight, 180, 255, 180);
    /* border highlight for cell on an opposite edge */
    init_rgb(c_edgematch, 127, 127, 127);
    init_rgb(c_text, 255, 255, 255);
    init_rgb(c_invtext, 0, 0, 0);
    init_rgb(c_canvas, 0, 0, 0);
    init_rgb(c_buttonborder, 0, 127, 0);
    init_rgb(c_server, 0, 0, 191);
    init_rgb(c_serverwon, 0, 0, 255);
    init_rgb(c_on, 0, 255, 0);
    init_rgb(c_off, 127, 0, 0);
    init_rgb(c_up, 0, 255, 255);
    init_rgb(c_down, 127, 0, 127);
    init_rgb(c_windowborder, 0, 255, 0);
    init_rgb(c_pulse, 255, 255, 255);
    init_rgb(c_borderwon, 0, 127, 127);
    init_rgb(c_border, 0, 127, 0);
    /* background color for unmarked tile */
    init_rgb(c_unmarkedbg, 0, 0, 0);
    /* background color for marked tile */
    init_rgb(c_markedbg, 0, 0, 127);
}

void init_ctable(SDL_PixelFormat *format)
{
    int i;
    for (i=0; i<c_max; i++) {
	ctable[i] = SDL_MapRGB(format, rgbtable[i].r, rgbtable[i].g, rgbtable[i].b);
    }
}
