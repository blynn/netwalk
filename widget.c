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
#include "widget.h"
#include "colour.h"

void widget_computexy(widget_ptr wid)
{
    wid->x = wid->localx;
    wid->y = wid->localy;
    if (wid->parent) {
	wid->x += wid->parent->x;
	wid->y += wid->parent->y;
    }
}

void widget_init(widget_ptr wid)
{
    int i;

    wid->parent = NULL;
    wid->update = NULL;
    wid->handle_click = NULL;
    for (i=0; i<signal_count; i++) {
	wid->signal_handler[i] = NULL;
	wid->data[i] = NULL;
    }
    wid->computexy = widget_computexy;
}

void widget_put_geometry(void *p, int x, int y, int w, int h)
{
    struct widget_s *wid = (struct widget_s *) p;
    wid->localx = x;
    wid->localy = y;
    wid->w = w;
    wid->h = h;
}

void widget_put_handler(widget_ptr p, void (* f)(widget_ptr, void *), int sig)
{
    p->signal_handler[sig] = f;
}

void widget_put_handler_data(widget_ptr p,
	void (* f)(widget_ptr, void *), void *data, int sig)
{
    p->signal_handler[sig] = f;
    p->data[sig] = data;
}

void widget_fill(widget_ptr w, int c)
{
    SDL_Rect rect;
    rect.x = w->x;
    rect.y = w->y;
    rect.w = w->w;
    rect.h = w->h;

    SDL_FillRect(screen, &rect, ctable[c]);
}

void widget_fillrect(widget_ptr w, SDL_Rect *rect, int c)
{
    SDL_Rect r;

    r.x = rect->x + w->x;
    r.y = rect->y + w->y;
    r.w = rect->w;
    r.h = rect->h;
    SDL_FillRect(screen, &r, ctable[c]);
}

void widget_blit(void *p, SDL_Surface *s, SDL_Rect *src, SDL_Rect *dst)
{
    widget_ptr wid = (widget_ptr) p;
    dst->x += wid->x;
    dst->y += wid->y;
    SDL_BlitSurface(s, src, screen, dst);
    dst->x -= wid->x;
    dst->y -= wid->y;
}

void widget_raise_signal(widget_ptr w, int sig)
{
    void (*f)();
    f = w->signal_handler[sig];
    if (f) {
	f(w, w->data[sig]);
    }
}

void widget_update(void *p)
{
    ((widget_ptr) p)->update(p);
}

int in_widget(widget_ptr wid, int x, int y)
{
    return (wid->x <= x && x < wid->x + wid->w
		&& wid->y <= y && y < wid->y + wid->h);
}

void widget_box(widget_ptr w, int x0, int y0, int x1, int y1, int c)
{
    SDL_Rect r;

    r.x = w->x + x0;
    r.y = w->y + y0;
    r.w = x1 - x0 + 1;
    r.h = y1 - y0 + 1;
    SDL_FillRect(screen, &r, ctable[c]);
}

void widget_raised_border(widget_ptr rect)
{
    int x0, y0;
    x0 = rect->w - 1;
    y0 = rect->h - 1;
    widget_box(rect, 1, y0 - 1, x0 - 1, y0 - 1, c_shadow);
    widget_box(rect, x0 - 1, 1, x0 - 1, y0 - 1, c_shadow);

    widget_box(rect, 0, 0, x0, 0, c_highlight);
    widget_box(rect, 0, 0, 0, y0, c_highlight);

    widget_box(rect, 0, y0, x0, y0, c_darkshadow);
    widget_box(rect, x0, 0, x0, y0, c_darkshadow);
}

void widget_raised_background(widget_ptr rect)
{
    widget_fill(rect, c_background);
    widget_raised_border(rect);
}

void widget_lowered_border(widget_ptr rect)
{
    int x1, y1;
    x1 = rect->w - 1;
    y1 = rect->h - 2;
    widget_box(rect, 2, y1, x1 - 1, y1, c_background);
    widget_box(rect, x1 - 1, 2, x1 - 1, y1, c_background);
    y1++;
    widget_box(rect, 1, y1, x1 - 1, y1, c_highlight);
    widget_box(rect, x1, 1, x1, y1, c_highlight);

    widget_box(rect, 0, 0, 0, y1, c_shadow);
    widget_box(rect, 0, 0, x1, 0, c_shadow);

    widget_box(rect, 1, 1, 1, y1 - 1, c_darkshadow);
    widget_box(rect, 1, 1, x1 - 1, 1, c_darkshadow);
}

void widget_lowered_background(widget_ptr rect)
{
    widget_fill(rect, c_background);
    widget_lowered_border(rect);
}
