ALLFILES = ext_sdl.c bl*.[ch] version.h *.e Makefile LICENSE README HISTORY *.config *.se cross.ed

ifdef WIN32
CC = i586-mingw32msvc-gcc
EFLAGS=-boost -O2 -I /home/ben/cross/SDL/include/SDL
CFLAGS=-O2 -Wall -I /home/ben/cross/SDL/include/SDL
SDL_LIBS=-L /home/ben/cross/SDL/lib -lSDL
LIBS = $(SDL_LIBS) -lSDL_ttf 
else
CC = gcc
CFLAGS=-O2 -Wall `sdl-config --cflags`
EFLAGS=-boost -O2 `sdl-config --cflags`
SDL_LIBS=`sdl-config --libs`
LIBS = $(SDL_LIBS) -lSDL_ttf 
endif

target : netwalk

bl_lib.o : bl_lib.c

netwalk : *.e ext_sdl.c bl_lib.o
ifdef WIN32
	compile_to_c -cecil cecil.se -o $@.exe netwalk $(EFLAGS) ext_sdl.c bl_lib.o $(LIBS)
	ed -s netwalk.make < cross.ed
	. netwalk.make
else
	compile -cecil cecil.se $(EFLAGS) -o $@ netwalk ext_sdl.c bl_lib.o $(LIBS)
endif

clean :
	-rm netwalk *.o
	clean netwalk

projname := $(shell awk '/NETWALK_VERSION/ { print $$3 }' version.h )

dist: $(ALLFILES)
	-rm -rf $(projname)
	mkdir $(projname)
	cp -rl --parents $(ALLFILES) $(projname)
	tar chfz $(projname).tgz $(projname)
	-rm -rf $(projname)

ifdef WIN32
bindist : netwalk
	-rm -rf $(projname)
	mkdir $(projname)
	cp -l netwalk.exe $(projname)
	cp -l win32.config $(projname)/config
	cp -l /home/ben/cross/SDL/lib/SDL.dll $(projname)
	cp -l /home/ben/cross/SDL/lib/SDL_ttf.dll $(projname)
	zip $(projname)-win.zip $(projname)/*
	-rm -rf $(projname)
endif
