/* NetWalk main program
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
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>

#include <sys/types.h> //for opendir et al.
#include <dirent.h>

#include <sys/stat.h>
#include <unistd.h>

#include <stdlib.h>
#include <signal.h>

#include <SDL.h>
#include <SDL_ttf.h>

#include "version.h"

#include "widget.h"
#include "colour.h"
#include "game.h"

#include "config.h"
#include "util.h"

static int interrupted = 0;

enum {
    vsize = 18
};

enum {
    pulse_max = 1024
};

enum {
    state_game,
    state_button,
    state_quit
};

enum {
    level_easy = 0,
    level_medium,
    level_hard,
    level_veryhard,
    level_giant,
    level_absurd,
    level_max,
    level_custom
};

enum {
    cellw = 24,
    cellh = 24,
    border = 1,
    padding = 10
};

char shifttable[256];

struct hsentry_s {
    char *name;
    int time;
};
typedef struct hsentry_s *hsentry_ptr;
typedef struct hsentry_s hsentry_t[1];

hsentry_t hstable[level_max];
char *level_name[level_max];

//TODO use this somehow
struct gameparm_s {
    int boardw, boardh;
    int wrap;
};
typedef struct gameparm_s *gameparm_ptr;
typedef struct gameparm_s gameparm_t[1];

gameparm_t gp;

static config_t config;

SDL_Surface *screen;
TTF_Font *font;
int lastmousex, lastmousey;
char *player_name;
int game_won;
int state;

struct button_s {
    struct widget_s widget;
    char *text;
    SDL_Surface *img;
};
typedef struct button_s button_t[1];
typedef struct button_s *button_ptr;

struct label_s {
    struct widget_s widget;
    char *text;
    SDL_Surface *img;
};
typedef struct label_s label_t[1];
typedef struct label_s *label_ptr;

struct textbox_s {
    struct widget_s widget;
    char text[1024];
    int i;
    SDL_Surface *img;
};
typedef struct textbox_s textbox_t[1];
typedef struct textbox_s *textbox_ptr;

struct arena_s {
    struct widget_s widget;
};
typedef struct arena_s arena_t[1];
typedef struct arena_s *arena_ptr;

struct menuitem_s {
    struct widget_s widget;
    char *text;
    SDL_Surface *img;
    struct menu_s *submenu;
};
typedef struct menuitem_s menuitem_t[1];
typedef struct menuitem_s *menuitem_ptr;

struct menu_s {
    struct widget_s widget;
    //TODO: replace array with list
    menuitem_ptr item_list[64];
    int item_count;
};
typedef struct menu_s menu_t[1];
typedef struct menu_s *menu_ptr;

struct menubar_s {
    struct widget_s widget;
    //TODO: replace array with list
    menuitem_ptr item_list[64];
    int item_count;
};
typedef struct menubar_s menubar_t[1];
typedef struct menubar_s *menubar_ptr;

struct window_s {
    struct widget_s widget;
    //TODO: replace array with list
    struct widget_s *widget_list[64];
    int widget_count;

};
typedef struct window_s window_t[1];
typedef struct window_s *window_ptr;

struct hsw_s {
    label_t level;
    label_t time;
    label_t name;
};
typedef struct hsw_s *hsw_ptr;
typedef struct hsw_s hsw_t[1];

hsw_t hsw[level_max];

arena_t arena;
window_t root;
label_t l_moves;
label_t l_time;
menubar_t menu;
menuitem_ptr openedmenu;
window_ptr modalwindow;
window_t about_window;
window_t hs_window;
window_t enter_name_window;
label_t l_about1;
label_t l_about2;
button_t b_about1;
widget_t statusbar;

label_t l_hs1;
button_t b_hs1;

label_t l_en1;
textbox_t tb_en1;
button_t b_en1;

SDL_Surface *font_render(char *s, int c)
{
    return TTF_RenderText_Solid(font, s, rgbtable[c]);
}

void statusbar_update(widget_ptr w)
{
    widget_lowered_background(w);
}

void menu_init(menu_ptr m)
{
    widget_init((widget_ptr) m);
    m->item_count = 0;
}

void menu_update(menu_ptr m)
{
    int i;
    menuitem_ptr it;
    SDL_Rect rect;

    widget_fill((widget_ptr) m, c_background);
    for (i=0; i<m->item_count; i++) {
	it = m->item_list[i];
	if (in_widget((widget_ptr) it, lastmousex, lastmousey)) {
	    rect.x = 2;
	    rect.y = vsize * i;
	    rect.w = ((widget_ptr) it)->w - 4;
	    rect.h = vsize;
	    widget_fillrect((widget_ptr) m, &rect, c_menubg);
	}
	rect.x = 8;
	rect.y = vsize * i + 4;
	widget_blit((widget_ptr) m, it->img, NULL, &rect);
    }
}

void menu_add_item(menu_ptr m, menuitem_ptr it)
{
    m->item_list[m->item_count] = it;
    m->item_count++;
}

void menuitem_init(menuitem_ptr m)
{
    widget_init((widget_ptr) m);
    m->text = NULL;
    m->img = NULL;
    m->submenu = NULL;
}

menuitem_ptr menuitem_new()
{
    menuitem_ptr it;

    it = (menuitem_ptr) malloc(sizeof(menuitem_t));
    menuitem_init(it);

    return it;
}

void menuitem_put_text(menuitem_ptr m, char *s)
{
    SDL_Surface *tmp;

    m->text = s;
    if (m->img) SDL_FreeSurface(m->img);
    tmp = font_render(s, c_text);
    m->img = SDL_DisplayFormat(tmp);
    SDL_FreeSurface(tmp);
}

void open_submenu(widget_ptr p,	void *data)
{
    int i;
    int w = 0;
    menuitem_ptr it;

    openedmenu = (menuitem_ptr) p;
    menu_ptr m = openedmenu->submenu;

    for (i=0; i<m->item_count; i++) {
	it = m->item_list[i];
	if (w < it->img->w) w = it->img->w;
    }
    w += 12;

    m->widget.x = m->widget.parent->x;
    m->widget.y = m->widget.parent->y + vsize;

    m->widget.w = w;
    m->widget.h = vsize * m->item_count + 1;

    for (i=0; i<m->item_count; i++) {
	it = m->item_list[i];
	it->widget.x = 0 + m->widget.x;
	it->widget.y = vsize * i + 4 + m->widget.y;
	it->widget.w = w;
	it->widget.h = vsize;
    }
}

void menuitem_set_submenu(menuitem_ptr it, menu_ptr m)
{
    it->submenu = m;
    //it->widget.signal_handler[signal_activate] = open_submenu;
    widget_put_handler((widget_ptr) it, open_submenu, signal_activate);
    m->widget.parent = (widget_ptr) it;
}

void menubar_update(widget_ptr wid)
{
    SDL_Rect dst;
    menubar_ptr m = (menubar_ptr) wid;
    menuitem_ptr it;
    int i;

    widget_raised_background(wid);

    for (i=0; i<m->item_count; i++) {
	it = m->item_list[i];
	if (it == openedmenu) {
	    dst.x = it->widget.x + 2;
	    dst.y = it->widget.y + 2;
	    dst.w = it->widget.w - 4;
	    dst.h = vsize - 2;
	    widget_fillrect(wid, &dst, c_menubg);
	}
	if (it->img) {
	    dst.x = it->widget.x + 5;
	    dst.y = it->widget.y + 2;
	    widget_blit(m, it->img, NULL, &dst);
	}
    }
}

void menubar_handle_click(widget_ptr p, int button, int x, int y)
{
    int i;
    menubar_ptr m = (menubar_ptr) p;
    menuitem_ptr it;

    for (i=0; i<m->item_count; i++) {
	it = m->item_list[i];
	if (in_widget((widget_ptr) it, x, y)) {
	    widget_raise_signal((widget_ptr) it, signal_activate);
	    return;
	}
    }
}

void menubar_init(menubar_ptr m)
{
    widget_init((widget_ptr) m);
    m->widget.update = menubar_update;
    m->item_count = 0;
    m->widget.handle_click = menubar_handle_click;
}

void menubar_add_item(menubar_ptr m, menuitem_ptr it)
{
    m->item_list[m->item_count] = it;
    m->item_count++;
    it->widget.parent = (widget_ptr) m;
}

void menubar_auto_layout(menubar_ptr m)
{
    int i, x, y;
    menuitem_ptr it;

    x = 0;
    y = 0;
    for (i=0; i<m->item_count; i++) {
	it = m->item_list[i];
	if (it->img) {
	    it->widget.x = x;
	    it->widget.y = y;
	    it->widget.w = it->img->w + 10;
	    it->widget.h = it->img->h;
	    x += it->img->w + 10;
	}
    }
}

void label_update(widget_ptr p)
{
    SDL_Rect dst;
    label_ptr l = (label_ptr) p;

    if (l->img) {
	dst.x = 0;
	dst.y = 4;
	widget_blit(l, l->img, NULL, &dst);
    }
}

void label_init(label_ptr l)
{
    widget_init((widget_ptr) l);
    l->text = NULL;
    l->img = NULL;
    l->widget.update = label_update;
}

void label_put_text(label_ptr l, char *s)
{
    SDL_Surface *tmp;

    if (l->img) SDL_FreeSurface(l->img);
    if (l->text) free(l->text);
    l->text = clonestr(s);
    tmp = font_render(s, c_text);
    l->img = SDL_DisplayFormat(tmp);
    SDL_FreeSurface(tmp);
}

void textbox_update_img(textbox_ptr tb)
{
    SDL_Surface *tmp;

    if (tb->img) SDL_FreeSurface(tb->img);
    tmp = font_render(tb->text, c_text);
    if (tmp) {
	tb->img = SDL_DisplayFormat(tmp);
	SDL_FreeSurface(tmp);
    } else {
	tb->img = NULL;
    }
}

void textbox_left(textbox_ptr tb)
{
    if (tb->i > 0) tb->i--;
}

void textbox_right(textbox_ptr tb)
{
    if (tb->i < strlen(tb->text)) tb->i++;
}

void textbox_delete(textbox_ptr tb)
{
    if (tb->i > 0) {
	tb->i--;
	tb->text[tb->i] = 0;
	textbox_update_img(tb);
    }
}

void textbox_backspace(textbox_ptr tb)
{
    char *s = &tb->text[tb->i];
    if (tb->i) {
	memmove(s - 1, s, strlen(s) + 1);
	tb->i--;
	textbox_update_img(tb);
    }
}

void textbox_insert(textbox_ptr tb, char c)
{
    char *s = &tb->text[tb->i];
    memmove(s + 1, s, strlen(s) + 1);
    tb->text[tb->i] = c;
    tb->i++;
    textbox_update_img(tb);
}

void textbox_update(widget_ptr p)
{
    SDL_Rect dst;
    textbox_ptr tb = (textbox_ptr) p;

    dst.x = 0;
    dst.y = 0;
    dst.w = p->w;
    dst.h = p->h;
    widget_fillrect(p, &dst, c_text);
    dst.x++;
    dst.y++;
    dst.w-=2;
    dst.h-=2;
    widget_fillrect(p, &dst, c_canvas);

    if (tb->img) {
	dst.x = 1;
	dst.y = 3;
	widget_blit(tb, tb->img, NULL, &dst);
    }

    {
	char s[1024];
	int w, h;

	strncpy(s, tb->text, tb->i);
	s[tb->i] = 0;
	TTF_SizeText(font, s, &w, &h);

	dst.x = w;
	dst.y = 2;
	dst.w = 1;
	dst.h = vsize - 2;
	widget_fillrect(p, &dst, c_text);
    }
}

void textbox_init(textbox_ptr l)
{
    widget_init((widget_ptr) l);
    l->img = NULL;
    l->widget.update = textbox_update;
}

void textbox_put_text(textbox_ptr tb, char *s)
{
    strcpy(tb->text, s);
    tb->i = strlen(s);
    textbox_update_img(tb);
}

static widget_ptr button_selection;

void button_handle_click(widget_ptr p, int button, int x, int y)
{
    state = state_button;
    button_selection = p;
}

void button_update(widget_ptr p)
{
    SDL_Rect dst;
    label_ptr l = (label_ptr) p;

    if (state == state_button && button_selection == p
	    && in_widget(p, lastmousex, lastmousey)) {
	widget_lowered_background(p);
    } else {
	widget_raised_background(p);
    }
    if (l->img) {
	dst.x = 5;
	dst.y = 2;
	widget_blit(l, l->img, NULL, &dst);
    }
}

void button_init(button_ptr b)
{
    widget_init((widget_ptr) b);
    b->text = NULL;
    b->img = NULL;
    b->widget.update = button_update;
    b->widget.handle_click = button_handle_click;
}

void button_put_text(button_ptr b, char *s)
{
    SDL_Surface *tmp;

    if (b->img) SDL_FreeSurface(b->img);
    if (b->text) free(b->text);
    b->text = clonestr(s);
    tmp = font_render(s, c_text);
    b->img = SDL_DisplayFormat(tmp);
    SDL_FreeSurface(tmp);
}

void set_video(int w, int h)
{
    int flags;
    flags = SDL_DOUBLEBUF;

    screen = SDL_SetVideoMode(w, h, 0, flags);
    init_ctable(screen->format);

    if (!screen) {
	fprintf(stderr, "Can't set video mode: %s\n", SDL_GetError());
	exit(1);
    }

    //SDL_ShowCursor(SDL_DISABLE);
}

void set_interrupted(int i)
{
    interrupted = 1;
}

void init()
{
    int status;

    signal(SIGINT, set_interrupted);
    signal(SIGTERM, set_interrupted);

    //if (SDL_Init(SDL_INIT_AUDIO|SDL_INIT_VIDEO|SDL_INIT_TIMER) < 0) {
    if (SDL_Init(SDL_INIT_VIDEO|SDL_INIT_TIMER) < 0) {
	fprintf(stderr, "Can't init SDL: %s\n", SDL_GetError());
	exit(1);
    }
    atexit(SDL_Quit);
    status = TTF_Init();
    if (status) {
	fprintf(stderr, "Can't init SDL_ttf\n");
	exit(-1);
    }
    atexit(TTF_Quit);

    SDL_WM_SetCaption("NetWalk", "NetWalk");

    SDL_EnableKeyRepeat(150, 50);
}

SDL_Surface *unmarked_tileimg[64];
SDL_Surface *marked_tileimg[64];
int level = level_medium;
int tick;
int tick_old;
int pipey, pipex;
int pipew, pipeh;
int pipet = 4;
int move_count;
int ms_count;
int second_count;

void draw_tile(widget_ptr wid, int i, int j)
{
    SDL_Rect rect;
    int index;

    rect.x = padding + border + i * (cellw + border);
    rect.y = padding + border + j * (cellh + border);

    int const marked = flags[i][j] & 0x1;
    index = board[i][j] - 1;
    widget_blit(wid,
	(marked?marked_tileimg:unmarked_tileimg)[index],
	NULL,
	&rect);
}

typedef struct {
    int x, y;
    int dir;
    int tick;
} pulse_s;

pulse_s pulse_list[pulse_max];
int pulse_count;

void new_pulse(int x, int y, int d)
{
    int i, j;

    if (pulse_count >= pulse_max) return;

    //stop incoming server pulses
    if (x == sourcex && (y == sourceybottom || y ==sourceytop) && d != -1) {
	return;
    }

    i = board[x][y];
    for (j=0; j<4; j++) {
	if ((j != d) && (i & (1 << j))) {
	    pulse_list[pulse_count].x = x;
	    pulse_list[pulse_count].y = y;
	    pulse_list[pulse_count].dir = j;
	    pulse_list[pulse_count].tick = tick;
	    pulse_count++;
	    if (pulse_count >= pulse_max) return;
	}
    }
}

void server_pulse()
{
    new_pulse(sourcex, sourceybottom, -1);
    new_pulse(sourcex, sourceytop, -1);
}

void animate_pulse(widget_ptr wid)
{
    int i, dt, d;
    int x, y;
    SDL_Rect rect;
    int speed = 500;

    if (!pulse_count) {
	server_pulse();
    }

    rect.w = pipet + 2;
    rect.h = pipet + 2;
    i = 0;
    while (i<pulse_count) {
	x = pulse_list[i].x;
	y = pulse_list[i].y;
	d = pulse_list[i].dir;
	dt = tick - pulse_list[i].tick;
	if (dt > speed) {
	    pulse_count--;
	    memmove(&pulse_list[i], &pulse_list[i+1], sizeof(pulse_s) * (pulse_count - i));

	    add_dir(&x, &y, x, y, d);
	    new_pulse(x, y, (d + 2) % 4);
	} else {
	    //wrap cases:
	    if (dir[d].x == -1 && 2 * dt > speed && !x) {
		x += boardw;
	    }
	    if (dir[d].x == 1 && 2 * dt > speed && x == boardw - 1) {
		x -= boardw;
	    }
	    if (dir[d].y == -1 && 2 * dt > speed && !y) {
		y += boardh;
	    }
	    if (dir[d].y == 1 && 2 * dt > speed && y == boardh - 1) {
		y -= boardh;
	    }

	    rect.x = x * (cellw + border) + pipex - 1;
	    rect.x += dir[d].x * (cellw + border) * dt / speed;
	    rect.x += border + padding;

	    rect.y = y * (cellh + border) + border + padding;
	    rect.y += dir[d].y * (cellh + border) * dt / speed;
	    rect.y += pipey - 1;
	    widget_fillrect(wid, &rect, c_pulse);
	    i++;
	}
    }
}

/** \brief Determine which cell of the arena the mouse is currently
 * pointing at, if any.
 * \param wid The arena widget.
 * \param mousex The mouse X position.
 * \param mousey The mouse Y position.
 * \param[out] col_p Returns the current cell's column in the arena.
 * \param[out] row_p Returns the current cell's row in the arena.
 * \retval 0 The mouse is over the arena and the cell index is returned
 * through \a row_p and \a col_p.
 * \retval -1 The mouse is not over the area.
 */

int get_cell_from_mouse_position(widget_ptr const wid,
	int const mousex,int const mousey,
	unsigned int * const col_p,unsigned int * const row_p)
{
	if((mousex < wid->x) || (mousey < wid->y))
		return -1;

	unsigned int const col =
		(mousex - padding - border - wid->x) / (cellw + border);
	unsigned int const row =
		(mousey - padding - border - wid->y) / (cellh + border);

	if((col >= boardw) || (row >= boardh))
		return -1;

	*col_p = col;
	*row_p = row;
	return 0;
}

/** \brief Fill a cell (including border) in the arena with a color.
 * \param wid The arena widget.
 * \param col The column of the cell to be filled.
 * \param row The row of the cell to be filled.
 * \param coloridx The index of the color to use when filling.
 */

void fill_arena_cell(widget_ptr const wid,
	unsigned int const col,unsigned int const row,int const coloridx)
{
	SDL_Rect rect = {
		.x = (cellw + border) * col + padding,
		.y = (cellh + border) * row + padding,
		.w = cellw + 2 * border,
		.h = cellh + 2 * border
	};
	widget_fillrect(wid, &rect, coloridx);
}

void arena_update(widget_ptr wid)
{
    int i, j;
    SDL_Rect rect;
    int bc;
    int c;

    //draw grid
    rect.x = padding;
    rect.y = padding;
    rect.w = cellw * boardw + (boardw + 1) * border;
    rect.h = border;

    if (game_won) bc = c_borderwon;
    else bc = c_border;

    for (i=0; i<=boardh; i++) {
	widget_fillrect(wid, &rect, bc);
	rect.y += cellh + border;
    }

    rect.y = padding;
    rect.w = border;
    rect.h = cellh * boardh + (boardh + 1) * border;
    for (i=0; i<=boardw; i++) {
	widget_fillrect(wid, &rect, bc);
	rect.x += cellw + border;
    }

    //highlight cursor
    unsigned int col;
    unsigned int row;
    if(get_cell_from_mouse_position(wid,lastmousex,lastmousey,&col,&row) == 0)
    {
	/* highlight the cell the mouse is pointing at */
	fill_arena_cell(wid,col,row,c_highlight);

	if(wrap_flag)
	{
		/*
		 * If the highlighted cell is an edge cell, also
		 * highlight the corresponding cells on opposite
		 * edges.  This will make it easier to work with large
		 * wrapped grids.
		 */
		if(col == 0)
			fill_arena_cell(wid,boardw - 1,row,c_edgematch);
		else
		if(col == boardw - 1)
			fill_arena_cell(wid,0,row,c_edgematch);

		if(row == 0)
			fill_arena_cell(wid,col,boardh - 1,c_edgematch);
		else
		if(row == boardh - 1)
			fill_arena_cell(wid,col,0,c_edgematch);
	}
    }

    //draw in tiles
    for (i=0; i<boardw; i++) {
	for (j=0; j<boardh; j++) {
	    if (board[i][j]) {
		draw_tile(wid, i, j);
	    }
	}
    }
    //draw server
    if (game_won) c = c_serverwon;
    else c = c_server;

    rect.x = padding + border + (cellw + border) * sourcex;
    rect.y = padding + border + (cellh + border) * sourceytop;

    rect.x += 5;
    rect.y += 5;
    rect.w = cellw - 10;
    rect.h = cellh - 5;
    widget_fillrect(wid, &rect, c);

    rect.y = padding + border + (cellh + border) * sourceybottom;
    widget_fillrect(wid, &rect, c);

    //victory animation
    if (game_won) {
	animate_pulse(wid);
    }
}

char* read_field(FILE *fp)
{
    char *r;
    int i;
    char c;

    r = (char *) malloc(1024);
    i = 0;

    for(;;) {
	c = getc(fp);

	if (feof(fp)) {
	    free(r);
	    return NULL;
	}

	switch(c) {
	    case ',':
		r[i] = 0;
		return r;
	    case '\n':
		r[i] = 0;
		return r;
	    default:
		r[i] = c;
		i++;
		break;
	}
    }
}

void update_hsw()
{
    int i;
    for (i=0; i<level_max; i++) {
	if (hstable[i]->name) {
	    label_put_text(hsw[i]->name, hstable[i]->name);
	} else {
	    label_put_text(hsw[i]->name, "None");
	}
	if (hstable[i]->time != -1) {
	    char s[80];

	    sprintf(s, "%d", hstable[i]->time);
	    label_put_text(hsw[i]->time, s);
	} else {
	    label_put_text(hsw[i]->name, "None");
	}
    }
}

void read_hstable()
{
    FILE *fp;
    int i;

    for (i=0; i<level_max; i++) {
	hstable[i]->name = NULL;
	hstable[i]->time = -1;
    }

    fp = fopen(config->hsfile, "r");
    if (!fp) return;

    for(i=0; i<level_max; i++) {
	char *s;
	s = read_field(fp);
	if (!s) goto done;

	hstable[i]->name = s;

	s = read_field(fp);
	if (!s) goto done;

	hstable[i]->time = atoi(s);
	free(s);
    }

done:
    fclose(fp);
}

void write_hstable()
{
    FILE *fp;
    int i;

    fp = fopen(config->hsfile, "w");
    if (!fp) return;

    for(i=0; i<level_max; i++) {
	fprintf(fp, "%s,%d\n", hstable[i]->name, hstable[i]->time);
    }

    fclose(fp);
}

int enkludge;

void enter_name_open()
{
    modalwindow = enter_name_window;
    enkludge = 1;
}

void enter_name_close()
{
    modalwindow = NULL;
    enkludge = 0;

    player_name = tb_en1->text;

    if (hstable[level]->name) {
	free(hstable[level]->name);
    }
    hstable[level]->name = clonestr(player_name);
    hstable[level]->time = second_count;
    update_hsw();
    write_hstable();
}

void check_hs()
{
    if (hstable[level]->time == -1 || second_count < hstable[level]->time) {
	enter_name_open();
    }
}

void init_tileimg(SDL_Surface * tileimg[64],int bgcolor)
{
    int i, j;
    SDL_PixelFormat *fmt = screen->format;
    SDL_Rect rect;
    int c;

    pipex = cellw / 2 - pipet / 2;
    pipey = cellw / 2 - pipet / 2;
    pipew = cellw / 2 + pipet / 2;
    pipeh = cellh / 2 + pipet / 2;

    SDL_Rect entirecell = (SDL_Rect){
	.x = 0,
	.y = 0,
	.w = cellw,
	.h = cellh
    };

    for (i=0; i<64; i++) {
	tileimg[i] = SDL_CreateRGBSurface(0, cellw, cellh, fmt->BitsPerPixel,
	    fmt->Rmask, fmt->Gmask, fmt->Bmask, fmt->Amask);

	SDL_FillRect(tileimg[i], &entirecell, ctable[bgcolor]);

	for (j=0; j<4; j++) {
	    if ((i + 1) & (1 << j)) {
		switch (j) {
		    case 0:
			rect.x = pipex;
			rect.y = 0;
			rect.w = pipet;
			rect.h = pipeh;
			break;
		    case 1:
			rect.x = pipex;
			rect.y = pipey;
			rect.w = pipew;
			rect.h = pipet;
			break;
		    case 2:
			rect.x = pipex;
			rect.y = pipey;
			rect.w = pipet;
			rect.h = pipeh;
			break;
		    case 3:
			rect.x = 0;
			rect.y = pipey;
			rect.w = pipew;
			rect.h = pipet;
			break;
		}
		if (i >= 16) {
		    c = ctable[c_on];
		} else c = ctable[c_off];
		SDL_FillRect(tileimg[i], &rect, c);
	    }
	}
    }

    for (i=1; i<32; i*=2) {
	rect.x = cellw / 2 - 2 * pipet;
	rect.y = cellh / 2 - 2 * pipet;
	rect.w = pipet * 4;
	rect.h = pipet * 4;
	rect.x++;
	rect.w-=2;
	rect.y++;
	rect.h-=2;
	/*
	SDL_FillRect(tileimg[i-1], &rect, ctable[c_off]);
	SDL_FillRect(tileimg[i-1+16], &rect, ctable[c_on]);
	rect.x++;
	rect.w-=2;
	rect.y++;
	rect.h-=2;
	*/
	SDL_FillRect(tileimg[i-1], &rect, ctable[c_down]);
	SDL_FillRect(tileimg[i-1+16], &rect, ctable[c_up]);
    }
}

void reset_move_count()
{
    move_count = 0;
    label_put_text(l_moves, "moves: 0");
}

void increment_move_count()
{
    char s[80];
    move_count++;
    sprintf(s, "moves: %d", move_count);
    label_put_text(l_moves, s);
}

void reset_time()
{
    label_put_text(l_time, "time: 0");
}

void update_time()
{
    static char s[80];

    ms_count += tick - tick_old;
    while (ms_count >= 1000) {
	ms_count -= 1000;
	second_count++;
	sprintf(s, "time: %d", second_count);
	label_put_text(l_time, s);
    }
}

void resize()
//position everything based on board size
{
    int w, h;

    sourcex = boardw / 2 - 1;
    sourceytop =  boardh / 2;
    sourceybottom = sourceytop + 1;

    w = cellw * boardw + (boardw + 1) * border + 2 * padding;
    h = cellh * boardh + (boardh + 1) * border + 2 * padding;
    widget_put_geometry(arena, 0, vsize, w, h);
    set_video(w, h + 2 * vsize);
    widget_put_geometry(root, 0, 0, w, h + 2 * vsize);
    widget_put_geometry(menu, 0, 0, w, vsize);
    menubar_auto_layout(menu);
    widget_put_geometry(statusbar, 0, h + vsize, w, vsize);

    widget_put_geometry(l_moves, 8, h + vsize, 64, vsize);
    widget_put_geometry(l_time, w - 48, h + vsize, 64, vsize);

    widget_put_geometry((widget_ptr) about_window,
	    w/2 - 50, h/2 - 50, 100, 100);
    widget_put_geometry((widget_ptr) l_about1, 10, 10, 60, vsize);
    widget_put_geometry((widget_ptr) l_about2, 10, 30, 60, vsize);
    widget_put_geometry((widget_ptr) b_about1, 30, 80, 30, vsize);

    /* vertical sizes and positions for the high score window */
    int const hslabely = 5;
    int const hslabelheight = vsize;
    int const hslisty = hslabely + hslabelheight + 8;
    int const hslisteachheight = vsize;
    int const hslistheight = hslisteachheight * level_max;
    int const hsoky = hslisty + hslistheight + 8;
    int const hsokheight = vsize;
    int const hswindowheight = hsoky + hsokheight + 5;

    widget_put_geometry((widget_ptr) hs_window,
	    w/2 - 75, h/2 - 60, 170, hswindowheight);
    widget_put_geometry((widget_ptr) l_hs1, 10, hslabely, 60, hslabelheight);
    widget_put_geometry((widget_ptr) b_hs1, 100, hsoky, 30, hsokheight);

    {
	int i;
	for (i=0; i<level_max; i++) {
	    int y = hslisty + (hslisteachheight * i);
	    widget_put_geometry((widget_ptr) hsw[i]->level,
		10, y, 20, hslisteachheight);
	    widget_put_geometry((widget_ptr) hsw[i]->time,
		60, y, 20, hslisteachheight);
	    widget_put_geometry((widget_ptr) hsw[i]->name,
		90, y, 20, hslisteachheight);
	}
    }

    widget_put_geometry((widget_ptr) enter_name_window,
	    10, h/2 - 30, w - 20, 67);
    widget_put_geometry((widget_ptr) l_en1, 10, 0, 60, vsize);
    widget_put_geometry((widget_ptr) tb_en1, 5, vsize + 5, w - 30, vsize);
    widget_put_geometry((widget_ptr) b_en1, w - 60, 45, 30, vsize);

    ((widget_ptr) root)->computexy((widget_ptr) root);
    ((widget_ptr) about_window)->computexy((widget_ptr) about_window);
    ((widget_ptr) hs_window)->computexy((widget_ptr) hs_window);
    ((widget_ptr) enter_name_window)->computexy((widget_ptr) enter_name_window);
}

void new_game()
{
    char s[BUFSIZ];
    strcpy(s,"NetWalk - ");
    strcat(s,level_name[level]);
    SDL_WM_SetCaption(s,s);

    switch(level) {
	case level_easy:
	    boardw = 5; boardh = 5;
	    wrap_flag = 0;
	    no_fourway = 0;
	    break;
	case level_medium:
	    boardw = 10; boardh = 9;
	    wrap_flag = 0;
	    no_fourway = 0;
	    break;
	case level_hard:
	    boardw = 10; boardh = 9;
	    wrap_flag = 1;
	    no_fourway = 1;
	    break;
	case level_veryhard:
	    boardw = 20; boardh = 18;
	    wrap_flag = 1;
	    no_fourway = 1;
	    break;
	case level_giant:
	    boardw = 50; boardh = 50;
	    wrap_flag = 0;
	    no_fourway = 1;
	    break;
	case level_absurd:
	    boardw = 50; boardh = 50;
	    wrap_flag = 1;
	    no_fourway = 1;
	    break;
	default:
	    break;
    }
    resize();
    srand(time(NULL));
    generate_maze();
    clear_flags();
    scramble();
    check_live();
    reset_move_count();
    reset_time();
    ms_count = 0;
    tick = SDL_GetTicks();
    second_count = 0;
}

void handle_mousebuttonup(SDL_Event *event)
{
    int x = event->button.x;
    int y = event->button.y;
    if (openedmenu) {
	int i;
	menuitem_ptr it;
	menu_ptr m;

	m = openedmenu->submenu;
	for (i=0; i<m->item_count; i++) {
	    it = m->item_list[i];
	    if (in_widget((widget_ptr) it, x, y)) {
		widget_raise_signal((widget_ptr) it, signal_activate);
		break;
	    }
	}
	openedmenu = NULL;

	return;
    } else if (state == state_button) {
	state = state_game;
	if (in_widget(button_selection, x, y)) {
	    widget_raise_signal(button_selection, signal_activate);
	    return;
	}
    }
}

void handle_click(int button, int x, int y)
{
    widget_ptr wid;

    if (modalwindow) {
	wid = (widget_ptr) modalwindow;
	if (in_widget(wid, x, y) && (wid->handle_click)) {
	    wid->handle_click(wid, button, x, y);
	}
	return;
    }

    wid = (widget_ptr) root;
    wid->handle_click(wid, button, x, y);
}

void arena_handle_click(widget_ptr p, int button, int x, int y)
{
    int i, j;
    int d;

    if (state != state_game) return;

    i = (x - padding - border) / (cellw + border);
    j = (y - padding - border) / (cellh + border);
    if (i >= boardw || j >= boardh) return;

    if (game_won) {
	if (i == sourcex && (j == sourceytop || j == sourceybottom)) {
	    new_pulse(sourcex, sourceybottom, -1);
	    new_pulse(sourcex, sourceytop, -1);
	} else {
	    new_pulse(i, j, -1);
	}
	return;
    }

    //temporarily merge server squares
    board[sourcex][sourceybottom] |= board[sourcex][sourceytop] & 1;
    if (i == sourcex && j == sourceytop) {
	j = sourceybottom;
    }
    d = board[i][j] & 15;
    switch(button) {
	case SDL_BUTTON_LEFT:
	    d = rotatecw(d, 3);
	    increment_move_count();
	    break;
	case SDL_BUTTON_RIGHT:
	    d = rotatecw(d, 1);
	    increment_move_count();
	    break;
    }
    board[i][j] &= ~15;
    board[i][j] += d;

    board[sourcex][sourceytop] &= ~1;
    board[sourcex][sourceytop] |= board[sourcex][sourceybottom] & 1;
    board[sourcex][sourceybottom] &= ~1;

    if(button == SDL_BUTTON_MIDDLE)
	flags[i][j] ^= 0x1;

    check_live();
    if (game_won) {
	pulse_count = 0;

	check_hs();
    }
}

void quit()
{
    state = state_quit;
}

void quit_menu(widget_ptr w, void *data)
{
    quit();
}

void new_game_menu(widget_ptr w, void *data)
{
    new_game();
}

void about_open(widget_ptr w, void *data)
{
    modalwindow = about_window;
}

void about_close(widget_ptr w, void *data)
{
    modalwindow = NULL;
}

void hs_open(widget_ptr w, void *data)
{
    modalwindow = hs_window;
}

void hs_close(widget_ptr w, void *data)
{
    modalwindow = NULL;
}

void set_level(widget_ptr w, void *data)
{
    level = (int) data;
    new_game();
}

void handle_key(int key, int mod)
{
    if (openedmenu) {
	switch(key) {
	    case SDLK_ESCAPE:
		openedmenu = NULL;
	}
	return;
    }

    if (enkludge) {
	switch(key) {
	    case SDLK_LEFT:
		textbox_left(tb_en1);
		break;
	    case SDLK_RIGHT:
		textbox_right(tb_en1);
		break;
	    case SDLK_DELETE:
		textbox_delete(tb_en1);
		break;
	    case SDLK_BACKSPACE:
		textbox_backspace(tb_en1);
		break;
	    default:
		if (key < 256 && key >= 32) {
		    if (mod & KMOD_SHIFT) {
			textbox_insert(tb_en1, shifttable[key]);
		    } else {
			textbox_insert(tb_en1, key);
		    }
		}
		break;
	}
	return;
    }

    switch(key) {
	case SDLK_d:
	    enter_name_open();
	    break;
	case SDLK_ESCAPE:
	case SDLK_q:
	    quit();
	    break;
	case SDLK_F2:
	    new_game();
	    break;
    }
}

void update_screen()
{
    SDL_FillRect(screen, NULL, 0);
    widget_update((widget_ptr) root);
    if (openedmenu) {
	int i;
	menuitem_ptr it;

	for (i=0; i<menu->item_count; i++) {
	    it = menu->item_list[i];
	    if (in_widget((widget_ptr) it, lastmousex, lastmousey)) {
		open_submenu((widget_ptr) it, NULL);
	    }
	}
	menu_update(openedmenu->submenu);
    }
    if (modalwindow) {
	widget_update((widget_ptr) modalwindow);
    }
    SDL_Flip(screen);
}

void window_update(widget_ptr p)
{
    window_ptr w = (window_ptr) p;
    widget_ptr wid;
    int i;
    SDL_Rect dst;

    if (p != (widget_ptr) root) {
	dst.x = -1;
	dst.y = -1;
	dst.w = p->w + 2;
	dst.h = p->h + 2;
	widget_fillrect(p, &dst, c_windowborder);
	widget_fill(p, c_background);
    }

    for (i=0; i<w->widget_count; i++) {
	wid = w->widget_list[i];
	widget_update(wid);
    }
}

void window_handle_click(widget_ptr p, int button, int x, int y)
{
    widget_ptr wid;
    window_ptr window = (window_ptr) p;
    int i;

    for (i=0; i<window->widget_count; i++) {
	wid = window->widget_list[i];
	if (in_widget(wid, x, y) && (wid->handle_click)) {
	    wid->handle_click(wid, button, x - wid->x, y - wid->y);
	    return;
	}
    }
}

void window_add_widget(window_ptr r, void *p)
{
    widget_ptr wid = (widget_ptr) p;
    r->widget_list[r->widget_count] = wid;
    r->widget_count++;
    wid->parent = (widget_ptr) r;
    wid->x += r->widget.x;
    wid->y += r->widget.y;
}

void window_computexy(widget_ptr wid)
{
    int i;
    window_ptr w = (window_ptr) wid;

    widget_computexy(wid);
    for (i=0; i<w->widget_count; i++) {
	w->widget_list[i]->computexy(w->widget_list[i]);
    }
}

void window_init(window_ptr w)
{
    widget_init((widget_ptr) w);
    w->widget_count = 0;
    w->widget.update = window_update;
    w->widget.handle_click = window_handle_click;
    w->widget.computexy = window_computexy;
}

static void add_shiftstring(char *s1, char *s2)
{
    int i;

    for (i=0; i<strlen(s1); i++) {
	shifttable[(int) s1[i]] = s2[i];
    }
}

int main(int argc, char *argv[])
{
    SDL_Event event;

    //setup names
    level_name[level_easy] = "Newbie";
    level_name[level_medium] = "Normal";
    level_name[level_hard] = "Nerd";
    level_name[level_veryhard] = "Nutcase";
    level_name[level_giant] = "Nonsense";
    level_name[level_absurd] = "No Sleep";

    //setup shifttable
    {
	int i;

	for (i=0; i<256; i++) shifttable[i] = i;

	for (i='a'; i<='z'; i++) {
	    shifttable[i] = i - 32;
	}

	add_shiftstring("1234567890-=", "!@#$%^&*()_+");
	add_shiftstring("[]\\;',./`", "{}|:\"<>?~");
    }

    config_load(config);
    read_hstable();
    init();

    init_rgbtable();

    font = TTF_OpenFont(config->fontname, config->fontsize);
    if (!font) {
	fprintf(stderr, "error loading font %s\n", config->fontname);
	exit(1);
    }

    window_init(root);

    //need to set video mode here to initialize colour table
    set_video(100, 100);

    //setup enter name box
    {
	window_init(enter_name_window);

	label_init(l_en1);
	label_put_text(l_en1, "Enter name:");
	window_add_widget(enter_name_window, l_en1);

	textbox_init(tb_en1);
	textbox_put_text(tb_en1, "Anonymous");
	window_add_widget(enter_name_window, tb_en1);

	button_init(b_en1);
	button_put_text(b_en1, "Ok");
	window_add_widget(enter_name_window, b_en1);
	widget_put_handler((widget_ptr) b_en1, enter_name_close, signal_activate);
    }

    //setup the "arena": where the action is
    {
	widget_init((widget_ptr) arena);
	arena->widget.update = arena_update;
	arena->widget.handle_click = arena_handle_click;
	window_add_widget(root, arena);
    }

    //status bar: mainly for showing the time
    {
	widget_init((widget_ptr) statusbar);
	statusbar->update = statusbar_update;
	window_add_widget(root, statusbar);

	//setup moves and time
	label_init(l_moves);
	if (config->showmoves) {
	    window_add_widget(root, l_moves);
	}

	label_init(l_time);
	window_add_widget(root, l_time);
    }

    //setup the menus
    {
	menuitem_t it1, it2;
	menuitem_ptr it;
	menu_t m1, m2;

	int i;

	menubar_init(menu);
	window_add_widget(root, menu);
	menuitem_init(it1);
	menuitem_put_text(it1, "Game");
	menubar_add_item(menu, it1);
	menuitem_init(it2);
	menuitem_put_text(it2, "Help");
	menubar_add_item(menu, it2);

	menu_init(m1);

	it = menuitem_new();
	menuitem_put_text(it, "New game");
	widget_put_handler((widget_ptr) it, new_game_menu, signal_activate);
	menu_add_item(m1, it);

	for (i=0; i<level_max; i++) {
	    it = menuitem_new();
	    menuitem_put_text(it, level_name[i]);
	    widget_put_handler_data((widget_ptr) it,
		    set_level, (void *) i, signal_activate);
	    menu_add_item(m1, it);
	}
	it = menuitem_new();
	menuitem_put_text(it, "High Scores");
	widget_put_handler((widget_ptr) it, hs_open, signal_activate);
	menu_add_item(m1, it);
	it = menuitem_new();
	menuitem_put_text(it, "Quit");
	widget_put_handler((widget_ptr) it, quit_menu, signal_activate);
	menu_add_item(m1, it);

	menuitem_set_submenu(it1, m1);

	menu_init(m2);

	it = menuitem_new();
	menuitem_put_text(it, "About");
	widget_put_handler((widget_ptr) it, about_open, signal_activate);
	menu_add_item(m2, it);

	menuitem_set_submenu(it2, m2);
    }

    //setup about box
    {
	window_init(about_window);

	label_init(l_about1);
	label_put_text(l_about1, "NetWalk " VERSION_STRING);
	window_add_widget(about_window, l_about1);

	label_init(l_about2);
	label_put_text(l_about2, "Ben Lynn");
	window_add_widget(about_window, l_about2);

	button_init(b_about1);
	button_put_text(b_about1, "Ok");
	window_add_widget(about_window, b_about1);
	widget_put_handler((widget_ptr) b_about1, about_close, signal_activate);
    }

    //setup hiscores box
    {
	int i;
	window_init(hs_window);

	label_init(l_hs1);
	label_put_text(l_hs1, "High Scores");
	window_add_widget(hs_window, l_hs1);

	button_init(b_hs1);
	button_put_text(b_hs1, "Ok");
	window_add_widget(hs_window, b_hs1);
	widget_put_handler((widget_ptr) b_hs1, hs_close, signal_activate);

	for (i=0; i<level_max; i++) {
	    label_init(hsw[i]->level);
	    label_put_text(hsw[i]->level, level_name[i]);
	    window_add_widget(hs_window, hsw[i]->level);
	    label_init(hsw[i]->name);
	    window_add_widget(hs_window, hsw[i]->name);
	    label_init(hsw[i]->time);
	    window_add_widget(hs_window, hsw[i]->time);
	}
    }

    resize();

    update_hsw();

    init_tileimg(unmarked_tileimg,c_unmarkedbg);
    init_tileimg(marked_tileimg,c_markedbg);
    new_game();

    while (state != state_quit && !interrupted) {
	tick_old = tick;
	tick = SDL_GetTicks();
	if (!game_won) {
	    update_time();
	}
	SDL_GetMouseState(&lastmousex, &lastmousey);
	while (SDL_PollEvent(&event)) {
	    switch (event.type) {
		case SDL_KEYDOWN:
		    handle_key(event.key.keysym.sym, SDL_GetModState());
		    break;
		case SDL_MOUSEBUTTONDOWN:
		    handle_click(event.button.button, event.button.x, event.button.y);
		    break;
		case SDL_MOUSEBUTTONUP:
		    handle_mousebuttonup(&event);
		    break;
		case SDL_QUIT:
		    quit();
		    break;
	    }
	}
	update_screen();
	SDL_Delay(20);
    }
    return 0;
}
