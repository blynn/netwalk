#define bl_new(type) (type *) bl_malloc(sizeof (type));

void *bl_malloc(size_t size);
void bl_free(void *ptr);
