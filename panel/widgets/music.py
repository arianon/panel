from ..utils import aiopopen, check_output
from ..widget import Widget


async def music():
    """
    Fetches the current song from `mpc` and waits until `mpc idleloop`
    reports a `player` action (song switched, paused, unpaused or stopped)
    """
    widget = Widget()
    widget.icon = ' MPD '

    char_limit = 50

    async for mpc in _mpc_listener():
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

async def _mpc_listener():
    async with aiopopen('mpc idleloop player') as idleloop:
        yield await check_output('mpc')

        async for _ in idleloop:
            yield await check_output('mpc')
