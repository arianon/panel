from json import loads
from asyncio import sleep
import aiohttp

from ..widget import Widget

async def bitcoin():
    """
    Fetches the latest Bitcoin prices.
    """
    widget = Widget()
    widget.icon = ' USD '

    while True:
        data = await _fetch('http://api.bitven.com/prices')
        price = data['USD_TO_BSF_RATE']

        widget.text = "{:0.0f} Bs".format(price)

        yield widget

        await sleep(60 * 60)

async def _fetch(*args, **kwargs):
    async with aiohttp.ClientSession() as session:
        async with session.get(*args, **kwargs) as response:
            data = await response.text()
            return loads(data)
