import asyncio
import json
import sys
import traceback

from collections import defaultdict

from .widgets import *

PRODUCERS = (
    music,
    volume,
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
        write(widgets, end=',', flush=True)


async def consume(*producers):
    """
    Starts the workers, running them in parallel.

    This is where the black magic happens.
    """
    state = defaultdict(Widget)
    queue = asyncio.Queue()

    def exception_widget(ex):
        from xml.sax.saxutils import escape

        widget = Widget()

        name, text = type(ex).__name__, escape(str(ex))
        widget.text = f"<span background='red'>{name}</span>: {text}"

        return widget

    def print_exception():
        exc_info = traceback.format_exc().strip()

        line = '—' * max(map(len, exc_info.splitlines()))

        print(line, exc_info, line, sep='\n', file=sys.stderr)

    async def consume_agen(agen):
        name = agen.__name__

        try:
            async for widget in agen():
                await queue.put({name: widget})
        except (KeyboardInterrupt, asyncio.CancelledError):
            raise
        except Exception as ex:
            await queue.put({name: exception_widget(ex)})

            print_exception()

    for agen in producers:
        asyncio.ensure_future(consume_agen(agen))

    while True:
        state.update(await queue.get())

        yield [state[prod.__name__].to_dict()
               for prod in producers]
