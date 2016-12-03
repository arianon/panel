import asyncio
import json
import sys
import traceback

from collections import defaultdict

from .widgets import *

PRODUCERS = (
    music,
    volume,
    bitcoin,
    calendar,
    clock
)

async def start():
    """
    Receives the data from the workers queue and renders it to i3bar
    """

    def write(*args, **kwargs):
        print(json.dumps(*args, indent=2), **kwargs)

    write({'version': 1})

    # Begin infinite array.
    print('[[],')

    async for widgets in consume(*PRODUCERS):
        write(widgets, end=',\n', flush=True)


async def consume(*producers):
    """
    Starts the workers, running them in parallel.

    This is where the black magic happens.
    """
    state = defaultdict(Widget)
    queue = asyncio.Queue()

    async def consume_agen(agen):
        name = agen.__name__

        try:
            async for widget in agen():
                await queue.put({name: widget})
        except (KeyboardInterrupt, asyncio.CancelledError):
            raise
        except Exception as ex:
            w = Widget()
            w.text = '{} => {}'.format(type(ex).__name__, ex)
            w.border['color'] = 'red'
            w.border['bottom'] = 2
            await queue.put({name: w})

            exc_info = traceback.format_exc().strip()
            line = '—' * max(map(len, exc_info.splitlines()))

            print(line, exc_info, line, sep='\n', file=sys.stderr)

    for agen in producers:
        asyncio.ensure_future(consume_agen(agen))

    while True:
        state.update(await queue.get())

        yield [state[prod.__name__].to_dict() for prod in producers]