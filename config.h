#ifndef CONFIG_H
#define CONFIG_H

#include <stdio.h>

struct config_s {
    char *fontname;
    char *hsfile;
    int fontsize;
    int showmoves;
};
typedef struct config_s *config_ptr;
typedef struct config_s config_t[1];

void config_load(config_ptr config);
FILE *config_get_fp();

#endif //CONFIG_H
