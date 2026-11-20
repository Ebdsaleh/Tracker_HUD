def outer(value):
    def middle(value):
        def inner(value):
            return value

        return inner(value)

    return middle(value)
