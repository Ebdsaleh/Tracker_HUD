value = 0

def outer():
    value = 1

    def inner():
        nonlocal value
        value = 2

    return inner
