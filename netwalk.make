gcc -pipe -O2 -I/usr/include/SDL -D_REENTRANT `sdl-config --libs` -o netwalk netwalk.c ext_sdl.c bl_lib.c -lSDL_ttf 
strip netwalk
