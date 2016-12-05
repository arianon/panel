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

    async for pactl in _pulseaudio_listener():
        vol = re.search(r'([0-9]+)%', pactl).group(1)
        vol = int(vol)

        muted = 'Mute: yes' in pactl

        # Prevent fuck ups.
        if vol > 100:
            await aiopopen('pactl set-sink-volume 0 100%')

        if muted:
            widget.icon_color(background='#d54e53')
        else:
            widget.icon_color()  # Set back to default

        widget.text = mkbar(vol)

        yield widget


async def _pulseaudio_listener():
    async with aiopopen('pactl subscribe') as pactl:
        yield await check_output('pactl list sinks')

        async for event in pactl:
            # Only care about volume events.
            if 'sink' in event:
                yield await check_output('pactl list sinks')
