/* Tracker_HUD C adapter manual validation (C11).
 * Expected: translation unit, struct, function, parameters, declarations,
 * lexical compound blocks, branches, assignments, calls, returns.
 * This adapter does not emulate pointers or execution state.
 */
#include <stddef.h>
#define START_VALUE 2

typedef struct Counter {
    int value;
} Counter;

static int advance(Counter *counter, int amount) {
    int previous = counter->value;
    if (amount > 0) {
        counter->value = previous + amount;
    }
    return counter->value;
}

int main(void) {
    Counter counter = { START_VALUE };
    int result = advance(&counter, 3);
    return result == 5 ? 0 : 1;
}
