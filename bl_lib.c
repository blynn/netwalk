#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

void *bl_malloc(size_t size)
{
    void *result;

    result = malloc(size);
    if (!result) {
	perror("malloc");
	exit(1);
    }
    return result;
}

void bl_free(void *ptr)
{
    free(ptr);
}
