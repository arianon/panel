#!/usr/bin/env python3.6

import asyncio
import sys

def main():
    """
    Initialize the event loop and clean up when exitting.
    """
    try:
        from .panel import start

        loop = asyncio.get_event_loop()
        loop.run_until_complete(start())
    except KeyboardInterrupt:
        sys.exit(130)
    finally:
        pending = asyncio.Task.all_tasks()
        gathered = asyncio.gather(*pending)

        try:
            gathered.cancel()
            loop.run_until_complete(gathered)
            gathered.exception()
        except asyncio.CancelledError:
            pass
        finally:
            loop.close()


if __name__ == '__main__':
    main()
