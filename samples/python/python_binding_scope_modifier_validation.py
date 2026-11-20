module_value = 1
other_global = 2

def outer():
    closure_value = 10
    chain_value = 20

    class Holder:
        closure_value = 99

        def method(self):
            nonlocal closure_value
            closure_value = 11

    def middle():
        global module_value, other_global
        module_value = 3
        other_global += 1

        nonlocal chain_value
        chain_value = 21

        def inner():
            nonlocal chain_value
            chain_value += 1

    return Holder, middle
