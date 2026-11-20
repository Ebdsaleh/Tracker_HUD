type Pair[T] = tuple[T, T]

def transform[T, U: str](value: T, label: U) -> tuple[T, U]:
    def inner(item: T) -> T:
        return item
    return inner(value)

class Bundle[T, *Ts, **P]:
    item: T

    def get(self) -> T:
        return self.item

after = 1
