def outer(value):
    class Box:
        value = 0

        def method(self, value):
            return value

    return Box
