VERSION=0.4.12
ALLFILES = *.[ch] Makefile LICENSE README copyright linux/*.[ch] win32/*.[ch] Vera.ttf
PROJNAME = netwalk
OS ?= linux
ifeq ("$(OS)", "win32")
CC = i586-mingw32msvc-gcc
CFLAGS=-O2 -Wall -I /home/blynn/cross/SDL/include/SDL -I /home/blynn/cross/SDL_ttf/include -mwindows
SDL_LIBS=-L /home/blynn/cross/SDL/lib -lmingw32 -lSDLmain -lSDL
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
BINDIR = $(PREFIX)/bin
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
	cp -l /home/blynn/cross/SDL/lib/SDL.dll $(DISTNAME)
	cp -l /home/blynn/cross/SDL/lib/SDL_ttf.dll $(DISTNAME)
	zip $(DISTNAME)-win.zip $(DISTNAME)/*
	-rm -rf $(DISTNAME)
else

install : netwalk
	$(INSTALL) -d $(DESTDIR)$(BINDIR)
	$(INSTALL) -m 755 netwalk $(DESTDIR)$(BINDIR)
	$(INSTALL) -d $(DESTDIR)$(SHARE_DIR)
	$(INSTALL) -m 644 Vera.ttf $(DESTDIR)$(SHARE_DIR)

uninstall : clean
	-rm -f $(DESTDIR)$(BINDIR)/netwalk
	-rm -rf $(DESTDIR)$(SHARE_DIR)

endif

public :
	git push git+ssh://repo.or.cz/srv/git/netwalk.git master
	git push git@github.com:blynn/netwalk.git master
