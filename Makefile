VERSION=0.4.11
ALLFILES = *.[ch] Makefile LICENSE README copyright linux/*.[ch] win32/*.[ch] Vera.ttf
PROJNAME = netwalk
OS ?= linux
ifeq ("$(OS)", "win32")
CC = i586-mingw32msvc-gcc
CFLAGS=-O2 -Wall -I /home/ben/cross/SDL/include/SDL -mwindows
SDL_LIBS=-L /home/ben/cross/SDL/lib -lmingw32 -lSDLmain -lSDL
LIBS = $(SDL_LIBS) -lSDL_ttf
SHARE_DIR=.
else
CC = gcc
CFLAGS=-Wall -O2 -fomit-frame-pointer `sdl-config --cflags`
SDL_LIBS=`sdl-config --libs`
LIBS = $(SDL_LIBS) -lSDL_ttf
INSTALL = /usr/bin/install
PREFIX = /usr
SHARE_DIR=$(PREFIX)/share/netwalk
endif

.PHONY: target clean dist

target : version.h sharedir.h $(PROJNAME)

sharedir.h : ./Makefile
	echo '#define NETWALK_SHARE_DIR "'$(SHARE_DIR)'"' > sharedir.h

version.h : ./Makefile
	echo '#define VERSION_STRING "'$(VERSION)'"' > version.h

config_file.c : $(OS)/config_file.c
	ln -s $^ $@

$(PROJNAME) : main.c game.c colour.c widget.c config.c config_file.c
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

DISTNAME=$(PROJNAME)-$(VERSION)

clean :
	-rm $(PROJNAME) *.o version.h config_file.c sharedir.h

dist: $(ALLFILES) clean
	-rm -rf $(DISTNAME)
	mkdir $(DISTNAME)
	cp -rl --parents $(ALLFILES) $(DISTNAME)
	tar chfz $(DISTNAME).tgz $(DISTNAME)
	-rm -rf $(DISTNAME)

ifeq ("$(OS)", "win32")
zip : target
	-rm -rf $(DISTNAME)
	mkdir $(DISTNAME)
	cp -l LICENSE $(DISTNAME)
	cp -l $(PROJNAME) $(DISTNAME)/$(PROJNAME).exe
	cp -l *.ttf $(DISTNAME)
	#cp -l config $(DISTNAME)
	cp -l /home/ben/cross/SDL/lib/SDL.dll $(DISTNAME)
	cp -l /home/ben/cross/SDL/lib/SDL_ttf.dll $(DISTNAME)
	zip $(DISTNAME)-win.zip $(DISTNAME)/*
	-rm -rf $(DISTNAME)
else

install : netwalk
	$(INSTALL) -d $(PREFIX)/bin
	$(INSTALL) -m 755 netwalk $(PREFIX)/bin
	$(INSTALL) -d $(PREFIX)/share/$(PROJNAME)
	$(INSTALL) -m 644 Vera.ttf $(PREFIX)/share/$(PROJNAME)/

uninstall : clean
	-rm -f $(PREFIX)/bin/$(PROJNAME)
	-rm -rf $(PREFIX)/share/$(PROJNAME)

endif

public :
	git push https://code.google.com/p/netwalk/
	git push git+ssh://repo.or.cz/srv/git/netwalk.git
	git push git@github.com:blynn/netwalk.git
