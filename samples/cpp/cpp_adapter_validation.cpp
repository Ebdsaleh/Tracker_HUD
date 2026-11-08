// Tracker_HUD C++ adapter manual validation (C++17).
// Expected: namespace, class, method definitions, functions, template,
// lambda, range-based for, fields, parameters, and block scope.
// Structural facts only; no invented allocation/lifetime/value state.
#include <vector>

namespace tracker_hud_sample {

template <typename T>
T passthrough(T value) {
    return value;
}

class Counter {
public:
    explicit Counter(int start) : value_(start) {}

    void add(int amount) {
        if (amount > 0) {
            value_ += amount;
        }
    }

    int value() const {
        return value_;
    }

private:
    int value_;
};

struct Record {
    int id;
};

// Verify C++-specific defaulted parameter discovery independently of class
// methods and the generic C parameter_declaration grammar.
int with_default(int current, int fallback = 7) {
    return current == 0 ? fallback : current;
}

int run() {
    Counter counter(2);
    std::vector<int> items{1, 2};
    auto twice = [](int n) { return n * 2; };

    for (int item : items) {
        counter.add(twice(item));
    }

    Record record{ counter.value() };
    return passthrough(record.id);
}

} // namespace tracker_hud_sample

int main() {
    return tracker_hud_sample::run() == 8 ? 0 : 1;
}
