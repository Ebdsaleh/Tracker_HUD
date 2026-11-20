def unpack(values, obj, items):
    first, second = values
    head, (middle, tail) = values
    [left, *rest] = values
    obj.root, local_value = values
    items[0], final = values
    direct = values
    obj.direct = values
    items[1] = values
    return first, second, head, middle, tail, left, rest, local_value, final, direct
