ALLFILES = *.[ch] Makefile LICENSE README NEWS config helmetr.ttf
PROJNAME = netwalk
ifdef WIN32
CC = i586-mingw32msvc-gcc
EFLAGS=-boost -O2 -I /home/ben/cross/SDL/include/SDL
CFLAGS=-O2 -Wall -I /home/ben/cross/SDL/include/SDL -mwindows
SDL_LIBS=-L /home/ben/cross/SDL/lib -lmingw32 -lSDLmain -lSDL
LIBS = $(SDL_LIBS) -lSDL_ttf
else
CC = gcc
CFLAGS=-Wall -O2 -fomit-frame-pointer `sdl-config --cflags`
SDL_LIBS=`sdl-config --libs`
LIBS = $(SDL_LIBS) -lSDL_ttf 
endif
$(PROJNAME) : main.c
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

VERSION=0.4.1
DISTNAME=$(PROJNAME)-$(VERSION)

dist: $(ALLFILES)
	-rm -rf $(DISTNAME)
	mkdir $(DISTNAME)
	cp -rl --parents $(ALLFILES) $(DISTNAME)
	tar chfz $(DISTNAME).tgz $(DISTNAME)
	-rm -rf $(DISTNAME)

ifdef WIN32
bindist : $(PROJNAME)
	-rm -rf $(DISTNAME)
	mkdir $(DISTNAME)
	cp -l LICENSE $(DISTNAME)
	cp -l $(PROJNAME) $(DISTNAME)/$(PROJNAME).exe
	cp -l *.ttf $(DISTNAME)
	cp -l config $(DISTNAME)
	cp -l /home/ben/cross/SDL/lib/SDL.dll $(DISTNAME)
	cp -l /home/ben/cross/SDL/lib/SDL_ttf.dll $(DISTNAME)
	zip $(DISTNAME)-win.zip $(DISTNAME)/*
	-rm -rf $(DISTNAME)
endif

clean :
	-rm $(PROJNAME) *.o
