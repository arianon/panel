from psutil import virtual_memory
from asyncio import sleep, get_event_loop
from ..widget import Widget

loop = get_event_loop()


async def memory():
    widget = Widget()
    widget.icon = ' MEMORY '

    while True:
        percent = virtual_memory().percent
        widget.text = f'{percent}%'

        if percent > 90:
            widget.icon_color(background='#d54e53')
        if percent > 75:
            widget.icon_color(background='#e7c547')
        else:
            widget.icon_color()

        yield widget

        await sleep(0.5)
