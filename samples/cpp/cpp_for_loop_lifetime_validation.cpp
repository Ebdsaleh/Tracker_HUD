// Tracker_HUD C++ standard for-declaration lifetime validation.

int accumulate() {
    int total = 0;

    for (int i = 0; i < 3; ++i) {
        total += i;
    }

    int after = total;
    return after;
}
