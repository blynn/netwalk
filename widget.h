/* Very basic widgets for SDL
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
#ifndef WIDGET_H
#define WIDGET_H

#include <SDL.h>

enum {
    signal_activate = 0,
    signal_count
};

struct widget_s {
    int x, y;
    int w, h;
    int localx, localy;
    struct widget_s *parent;
    void (*update)(struct widget_s *);
    void (*handle_click)(struct widget_s *, int, int, int);
    void (*computexy)(struct widget_s *);
    //TODO: replace with hash table?
    void (*signal_handler[signal_count])(struct widget_s *w, void *data);
    void *data[signal_count];
};
typedef struct widget_s widget_t[1];
typedef struct widget_s *widget_ptr;

void widget_init(widget_ptr wid);
void widget_computexy(widget_ptr wid);
void widget_put_geometry(void *p, int x, int y, int w, int h);
void widget_put_handler(widget_ptr p, void (* f)(widget_ptr, void *), int sig);
void widget_put_handler_data(widget_ptr p,
	void (* f)(widget_ptr, void *), void *data, int sig);
void widget_fill(widget_ptr w, int c);
void widget_fillrect(widget_ptr w, SDL_Rect *rect, int c);
void widget_blit(void *p, SDL_Surface *s, SDL_Rect *src, SDL_Rect *dst);
void widget_raise_signal(widget_ptr w, int sig);
void widget_update(void *p);
int in_widget(widget_ptr wid, int x, int y);
void widget_raised_border(widget_ptr rect);
void widget_raised_background(widget_ptr rect);
void widget_lowered_border(widget_ptr rect);
void widget_lowered_background(widget_ptr rect);

extern SDL_Surface *screen;
#endif //WIDGET_H
