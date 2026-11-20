def build(source):
    before = source
    values = [
        (captured := item)
        for item in source
        if (seen := item) > 0
    ]
    nested = [
        [
            (deep := inner)
            for inner in range(outer_item)
        ]
        for outer_item in source
    ]
    after = (captured, seen, deep)
    return values, nested, after
