#include <stdlib.h>
#include "config.h"

#define DEFAULT_WINFONT "C:\\WINDOWS\\FONTS\\ARIAL.TTF"

char *config_file = "config";

FILE *config_get_fp()
{
    FILE *fp;

    fp = fopen(config_file, "r");
    if (!fp) {
	fp = fopen(config_file, "w");
	if (!fp) {
	    fprintf(stderr, "Can't open or create config file\n");
	    exit(1);
	}
	fprintf(fp, "font %s\n", DEFAULT_WINFONT);
	fprintf(fp, "fontsize 11\n");
	fprintf(fp, "hiscores hiscores.txt\n");
	fprintf(fp, "showmoves 0\n");
	fclose(fp);

	fp = fopen(config_file, "r");
	if (!fp) {
	    fprintf(stderr,"Can't open config file %s\n", config_file);
	    exit(1);
	}
    }

    return fp;
}
