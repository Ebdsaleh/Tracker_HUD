def outer[T]():
    lexical_value = 0

    def inner():
        nonlocal lexical_value
        lexical_value = 1
        nonlocal T
        T = 2
        return lexical_value, T

    return inner
