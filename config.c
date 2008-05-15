#include "config.h"
#include "util.h"

static void parse_option(config_ptr config, char *s1, char *s2)
{
    if (!strcmp(s1, "showmoves")) {
	config->showmoves = atoi(s2);
    }
    if (!strcmp(s1, "fontsize")) {
	config->fontsize = atoi(s2);
    }
    if (!strcmp(s1, "font")) {
	config->fontname = clonestr(s2);
    }
    if (!strcmp(s1, "hiscores")) {
	config->hsfile = clonestr(s2);
    }
}

static int is_whitespace(char c)
{
    if (strchr(" \t\r\n", c)) return -1;
    return 0;
}

static void skip_whitespace(FILE *fp)
{
    for (;;) {
	int c;
	c = getc(fp);
	if (feof(fp)) return;
	if (!is_whitespace(c)) {
	    ungetc(c, fp);
	    break;
	}
    }
}

/*
static void read_word(char *s, FILE *fp)
{
    int i = 0;

    skip_whitespace(fp);
    if (feof(fp)) return;

    for (;;) {
	int c;
	c = getc(fp);
	if (feof(fp)) return;
	if (is_whitespace(c)) {
	    ungetc(c, fp);
	    break;
	}
	s[i] = c;
	i++;
	if (i >= 128 - 1) break;
    }
    s[i] = 0;
}
*/

static void read_line(char *s, FILE *fp)
{
    int i = 0;

    for (;;) {
	int c;
	c = getc(fp);
	if (feof(fp)) return;
	if (c == '\r') {
	    //safest thing to do?
	    continue;
	}
	if (c == '\n') {
	    ungetc(c, fp);
	    break;
	}
	s[i] = c;
	i++;
	if (i >= 1024 - 1) break;
    }
    s[i] = 0;
}

void config_load(config_ptr config)
{
    FILE *fp;

    fp = config_get_fp();

    for(;;) {
	int i;
	char s1[1024], *s2;

	skip_whitespace(fp);
	if (feof(fp)) {
	    break;
	}
	read_line(s1, fp);
	if (feof(fp)) {
	    break;
	}

	i = 0;
	for(;;) {
	    if (!s1[i]) {
		s2 = &s1[i];
		break;
	    }
	    if (is_whitespace(s1[i])) {
		s1[i] = 0;
		i++;
		for(;;) {
		    if (!s1[i] || !is_whitespace(s1[i])) {
			s2 = &s1[i];
			break;
		    }
		}
		break;
	    }
	    i++;
	}

	parse_option(config, s1, s2);
    }

    fclose(fp);
}
