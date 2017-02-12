import re

from ..utils import aiopopen, check_output, mkbar
from ..widget import Widget


async def volume():
    """
    Fetches the volume from `pactl` and waits until `pactl subscribe`
    reports actions on the "sink" (volume stuff)
    """
    widget = Widget()
    widget.icon = ' VOL '

    async for vol, muted in _pulseaudio_listener():
        # Prevent fuck ups.
        # if vol > 100:
        #     await aiopopen('pactl set-sink-volume 0 100%')

        if muted:
            widget.icon_color(background='#d54e53')
        else:
            widget.icon_color()  # Set back to default

        widget.text = mkbar(vol)

        yield widget


async def _pulseaudio_listener():
    async def info():
        output = await check_output('pactl list sinks')
        vol = int(re.search(r'([0-9]+)%', output).group(1))
        muted = 'Mute: yes' in output

        return (vol, muted)

    async with aiopopen('pactl subscribe') as pactl:
        yield await info()

        async for event in pactl:
            # Only care about volume events.
            if 'sink' in event:
                yield await info()
