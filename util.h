#ifndef UTIL_H
#define UTIL_H

#include <stdlib.h>
#include <string.h>

static inline char *clonestr(char *s)
{
    char *res = malloc(sizeof(char) * strlen(s) + 1);
    strcpy(res, s);
    return res;
}

#endif //UTIL_H
