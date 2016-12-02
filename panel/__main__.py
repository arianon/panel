#!/usr/bin/env python3.6

import asyncio
import json
import sys
import traceback

from collections import defaultdict
from concurrent.futures import CancelledError

from .widget import Widget

from .clock import clock, calendar
from .bitcoin import bitcoin
from .music import music
from .volume import volume


async def start():
    """
    Receives the data from the workers queue and renders it to i3bar
    """

    def write(*args, **kwargs):
        print(json.dumps(*args), **kwargs)

    write({'version': 1})

    # Begin infinite array.
    print('[[],')

    async for widgets in consume(music, volume, bitcoin, calendar, clock):
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
        except (KeyboardInterrupt, CancelledError):
            raise
        except Exception as ex:
            w = Widget()
            w.text = ' {} => {} '.format(ex.__class__.__name__, ex)
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


def main():
    """
    Initialize the event loop and clean up when exitting.
    """
    try:
        loop = asyncio.get_event_loop()
        loop.run_until_complete(start())
    except KeyboardInterrupt:
        pending = asyncio.Task.all_tasks()
        gathered = asyncio.gather(*pending)

        try:
            gathered.cancel()
            loop.run_until_complete(gathered)
            gathered.exception()
        except CancelledError:
            pass
    finally:
        loop.close()


if __name__ == '__main__':
    main()
