from io import StringIO


def mkbar(value):
    value = max(min(value, 100), 0)
    value = round(value / 100 * 16)
    remainder = 16 - value

    output = StringIO()

    if value > 0:
        # output.write('<b>')
        output.write('—' * value)
        # output.write('</b>')
    if remainder > 0:
        output.write('<span foreground="#2a2a2a">')
        output.write('—' * remainder)
        output.write('</span>')

    value = output.getvalue()
    output.close()

    return value
