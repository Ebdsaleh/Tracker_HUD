T = 0

def outer[T]():
    def inner():
        global T
        T = 1
        return T

    return inner

after = T
