#include "config.h"
#include "sharedir.h"
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

FILE *config_get_fp()
{
    FILE *fp;

    char *home_dir = getenv("HOME");
    char *netwalk_dir;
    char *config_file;
    struct stat stbuf;

    if (!home_dir) {
	fprintf(stderr, "$HOME is not set\n");
	exit(1);
    }

    netwalk_dir = malloc(strlen(home_dir) + 100);
    config_file = malloc(strlen(home_dir) + 100);

    strcpy(netwalk_dir, home_dir);
    strcat(netwalk_dir,"/.netwalk");

    if (stat(netwalk_dir, &stbuf)) {
	if (mkdir(netwalk_dir, 0755)) {
	    fprintf(stderr, "Can't stat nor mkdir %s\n", netwalk_dir);
	    exit(1);
	}
    }

    strcpy(config_file, netwalk_dir);
    strcat(config_file, "/config");

    if (stat(config_file, &stbuf)) {
	fprintf(stderr, "Creating config file at %s\n", config_file);
	fp = fopen(config_file, "w");
	if (!fp) {
	    fprintf(stderr, "Can't create %s\n", config_file);
	    exit(1);
	}
	fprintf(fp, "font %s/Vera.ttf\n", NETWALK_SHARE_DIR);
	fprintf(fp, "fontsize 11\n");
	fprintf(fp, "hiscores %s/hiscores.txt\n", netwalk_dir);
	fprintf(fp, "showmoves 0\n");
	fclose(fp);
    }

    fp = fopen(config_file, "r");

    free(netwalk_dir);
    free(config_file);

    return fp;
}
