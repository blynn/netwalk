#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <SDL.h>
#include <SDL_ttf.h>
#include "bl_lib.h"
#include "version.h"
#include "eiffel.h"

static SDL_Surface *screen;

void ext_fill_rect(int x, int y, int w, int h, int c)
{
    SDL_Rect rect;

    rect.x = x;
    rect.y = y;
    rect.w = w;
    rect.h = h;
    SDL_FillRect(screen, &rect, c);
}

void video_init()
{

    //screen = SDL_SetVideoMode(640, 480, 0, SDL_HWSURFACE | SDL_DOUBLEBUF | SDL_FULLSCREEN);
    screen = SDL_SetVideoMode(640, 480, 0, SDL_HWSURFACE | SDL_DOUBLEBUF);
    //screen = SDL_SetVideoMode(640, 480, 0, SDL_SWSURFACE | SDL_FULLSCREEN);
    if (!screen) {
	fprintf(stderr, "Can't set video mode: %s\n", SDL_GetError());
	exit(1);
    }
    //SDL_ShowCursor(SDL_DISABLE);
}

void ext_init()
{
    int status;

    //printf("SDL_Init()...\n");
    //status = SDL_Init(SDL_INIT_AUDIO|SDL_INIT_VIDEO|SDL_INIT_TIMER);
    status = SDL_Init(SDL_INIT_VIDEO|SDL_INIT_TIMER);
    if (status < 0) {
	fprintf(stderr, "Can't init SDL: %s\n", SDL_GetError());
	exit(1);
    }
    atexit(SDL_Quit);
    //printf("TTF_Init()...\n");
    status = TTF_Init();
    if (status) {
	    fprintf(stderr, "init_glue: TTF_Init failed: %s\n", SDL_GetError());
	    exit(-1);
    }
    atexit(TTF_Quit);

    video_init();

    signal(SIGINT, exit);
    signal(SIGTERM, exit);

    SDL_WM_SetCaption(NETWALK_VERSION, NETWALK_VERSION);

    SDL_EnableKeyRepeat(SDL_DEFAULT_REPEAT_DELAY, SDL_DEFAULT_REPEAT_INTERVAL);
}

void ext_update_screen()
{
    SDL_Flip(screen);
}

EIF_OBJ ext_poll_event(EIF_OBJ em)
{
    SDL_Event event;

    while (SDL_PollEvent(&event)) {
	if (event.type == SDL_KEYDOWN) {
	    return EVENTMAKER_make_keydown(em, event.key.keysym.sym, SDL_GetModState());
	} else if (event.type == SDL_MOUSEBUTTONDOWN) {
	    return EVENTMAKER_make_mbdown(em, event.button.button, SDL_GetModState(), event.button.x, event.button.y);
	}
    }
    return NULL;
}

int is_kmod(int a, int b)
{
    return (a & b) != 0;
}

SDL_Surface *ext_render_text(char *s, TTF_Font *font, SDL_Color *c)
{
    SDL_Surface *tmp;
    SDL_Surface *res;

    tmp = TTF_RenderText_Solid(font, s, *c);
    res = SDL_DisplayFormat(tmp);
    SDL_FreeSurface(tmp);
    return res;
}

void *ext_make_color(int r, int g, int b)
{
    SDL_Color *res;

    res = (SDL_Color *) bl_malloc(sizeof(SDL_Color));
    res->r = r;
    res->g = g;
    res->b = b;

    return res;
}

int ext_convert_color(int r, int g, int b)
{
    return SDL_MapRGB(screen->format, r, g, b);
}

void blit_img(SDL_Surface *image, int x, int y)
{
    SDL_Rect rect;

    rect.x = x;
    rect.y = y;
    SDL_BlitSurface(image, NULL, screen, &rect);
}

SDL_Surface *ext_display_format_alpha(SDL_Surface *img)
{
    SDL_Surface *res;

    //assert(img);
    res = SDL_DisplayFormatAlpha(img);
    SDL_FreeSurface(img);
    return res;
}

SDL_Surface *ext_display_format(SDL_Surface *img)
{
    SDL_Surface *res;

    //assert(img);
    res = SDL_DisplayFormat(img);
    SDL_FreeSurface(img);
    return res;
}

TTF_Font *ext_ttf_openfont(char *font, int size)
{
    return TTF_OpenFont(font, size);
}

void *free_ttf_font(TTF_Font *font)
{
    TTF_CloseFont(font);
    return NULL;
}
