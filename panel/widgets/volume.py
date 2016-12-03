import re
from asyncio.subprocess import (
    create_subprocess_exec as aiopopen,
    PIPE
)

from ..widget import Widget
# from .utils import mkbar

async def volume():
    """
    Fetches the volume from `pactl` and waits until `pactl subscribe`
    reports actions on the "sink" (volume stuff)
    """
    widget = Widget()
    widget.icon = ' VOL '

    async for pactl in _pulseaudio_listener():
        vol = re.search(r'([0-9]+)%', pactl).group(1)
        vol = int(vol)

        muted = 'Mute: yes' in pactl

        # Prevent fuck ups.
        if vol > 100:
            await aiopopen('pactl', 'set-sink-volume', '0', '100%')

        if muted:
            widget.icon_color(background='#d54e53')
        else:
            widget.icon_color()  # Set back to default

        widget.text = '{}%'.format(vol)

        yield widget


async def _pulseaudio_listener():
    try:
        sub = await aiopopen('pactl', 'subscribe', stdout=PIPE)

        async def pactl():
            proc = await aiopopen('pactl', 'list', 'sinks', stdout=PIPE)
            stdout = await proc.stdout.read()
            return stdout.decode()

        yield await pactl()

        while True:
            message = await sub.stdout.readline()

            # Only care about volume events.
            if b'sink' in message:
                yield await pactl()
    finally:
        sub.kill()