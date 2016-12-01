from time import strftime
from datetime import datetime
from asyncio import sleep

from .widget import Widget


async def clock():
    """
    Computes the current time every second.
    """
    widget = Widget()
    widget.icon = ' TIME '

    while True:
        widget.text = strftime('%I:%M:%S %p')

        yield widget

        await sleep(1)


async def calendar():
    """
    Calculates the current date, and waits until tomorrow to do so again.
    """
    widget = Widget()
    widget.icon = ' DATE '

    while True:
        widget.text = strftime('%a %d %b')

        yield widget

        now = datetime.now()
        seconds_elapsed = (now.hour * 3600) - (now.minute * 60) - now.second
        seconds_until_tomorrow = 86400 - seconds_elapsed
        await sleep(seconds_until_tomorrow)
