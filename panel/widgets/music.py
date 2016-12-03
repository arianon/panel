from asyncio.subprocess import (
    create_subprocess_exec as aiopopen,
    PIPE
)

from ..widget import Widget


async def music():
    """
    Fetches the current song from `mpc` and waits until `mpc idleloop`
    reports a `player` action (song switched, paused, unpaused or stopped)
    """
    widget = Widget()
    widget.icon = ' MPD '

    char_limit = 50

    async for mpc in _mpd_listener():
        song = mpc.splitlines()[0]

        if len(song) > char_limit:
            song = song[:char_limit - 1] + '…'

        if '[playing]' in mpc:
            widget.icon_color()  # Set defaults
        elif '[paused]' in mpc:
            widget.icon_color(background='#e7c547')
        else:
            song = ''

        widget.text = song

        yield widget

async def _mpd_listener():
    try:
        idleloop = await aiopopen('mpc', 'idleloop', 'player', stdout=PIPE)

        while True:
            proc = await aiopopen('mpc', stdout=PIPE)
            stdout = await proc.stdout.read()
            stdout = stdout.decode()

            yield stdout

            await idleloop.stdout.readline()
    finally:
        idleloop.kill()
