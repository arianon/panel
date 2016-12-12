import asyncio

from ..widget import Widget


async def music():
    """
    Fetches the current song from MPD and waits until it reports
    a `player` action (song switched, paused, unpaused or stopped)
    """
    widget = Widget()
    widget.icon = ' MPD '

    char_limit = 50

    async for song, state in _mpd_listener():
        if len(song) > char_limit:
            song = song[:char_limit - 1] + '…'

        if state == 'play':
            widget.icon_color()  # Set defaults
        elif state == 'pause':
            widget.icon_color(background='#e7c547')
        else:
            song = ''

        widget.text = song

        yield widget


async def _mpd_listener(host='localhost', port=6600):
    sentinel = ('', None)

    try:
        reader, writer = await asyncio.open_connection(host, port)
    except OSError:
        yield sentinel
        return

    ack = await reader.readline()
    assert ack.startswith(b'OK MPD'), 'Failed to connect to MPD'

    async def command(cmd):
        writer.write((cmd + '\n').encode())

        try:
            data = await reader.readuntil(b'OK')
        except asyncio.IncompleteReadError:
            return None
        else:
            data = data.decode().strip('OK\n').splitlines()
            return dict(kv.split(': ') for kv in data)

    async def info():
        song = await command('currentsong')
        status = await command('status')

        if not song or not status:
            return sentinel

        return ('{Artist} - {Title}'.format(**song), status['state'])

    yield await info()
    while 1:
        event = await command('idle player')

        if not event:
            yield sentinel
            break

        yield await info()