def handle(value):
    before = value
    try:
        risky(value)
    except ValueError as err:
        first_seen = err
        first_copy = str(err)
    after_first = value

    try:
        grouped(value)
    except* Exception as group:
        group_seen = group
    after_group = value

    try:
        final(value)
    except Exception:
        handled = True
    done = value
