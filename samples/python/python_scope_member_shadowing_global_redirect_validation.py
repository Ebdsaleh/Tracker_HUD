value = 0

def outer(value):
    def inner():
        global value
        value = 1

    return inner
