/* Tracker_HUD C for-declaration lifetime validation (C11). */

int accumulate(void) {
    int total = 0;

    for (int i = 0; i < 3; ++i) {
        total += i;
    }

    int after = total;
    return after;
}
