def outer(value):
    def inner(value):
        return value

    return inner(value)
