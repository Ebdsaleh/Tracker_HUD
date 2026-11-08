// arch=x86-64;
// platform=windows;
// abi=win64;
// syntax=c;
// mode=compiled;

/* C source-observed heap operation validation.
 * No execution, ownership or leak conclusions are expected.
 * Comments and strings containing malloc(8) must not create heap facts.
 */
#include <stdlib.h>
#include <stddef.h>

void observe_c(size_t count) {
    const char *label = "malloc(8) is only text";
    void *block = malloc(count);
    void *zeroed = calloc(2, count);
    void *resized = realloc(block, count * 2);
    if (resized != NULL) {
        block = resized;
    }
    free(zeroed);
    free(block);
    (void)label;
}
