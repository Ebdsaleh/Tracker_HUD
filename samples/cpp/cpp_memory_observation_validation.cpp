// arch=x86-64;
// platform=windows;
// abi=win64;
// syntax=cpp;
// mode=compiled;

// C++ source-observed memory operations, not a leak/lifetime proof.
// The strings "new int" and "delete ptr" are not heap events.
void observe_cpp() {
    const char *label = "new int is text";
    int *single = new int(9);
    delete single;
    int *array = new int[2];
    delete[] array;
    (void)label;
}
