from asyncio.subprocess import create_subprocess_exec, PIPE
from shlex import split
from io import StringIO

def aiopopen(cmd):
    return _AIOPopen(cmd)

async def check_output(cmd, **kwargs):
    async with aiopopen(cmd, **kwargs) as aio:
        output = await aio.proc.stdout.read()
        return output.decode()

class _AIOPopen:
    def __init__(self, cmd, **kwargs):
        args = split(cmd)
        self.proc = None
        self.coro = create_subprocess_exec(*args, **kwargs, stdout=PIPE)

    def __await__(self):
        if not self.proc:
            self.proc = yield from self.coro
        return self

    def __aiter__(self):
        return self

    async def __anext__(self):
        if not self.proc:
            self.proc = await self.coro

        # Iterate over the lines of the process' standard output.
        line = await self.proc.stdout.readline()

        if line:
            return line.decode()
        else:
            raise StopAsyncIteration

    async def __aenter__(self):
        return await self

    async def __aexit__(self, *args):
        try:
            self.proc.terminate()
        except ProcessLookupError:
            pass


def mkbar(value):
    value = max(min(value, 100), 0)
    value = round(value / 100 * 16)
    remainder = 16 - value

    with StringIO() as output:
        if value > 0:
            # output.write('<b>')
            output.write('—' * value)
            # output.write('</b>')
        if remainder > 0:
            output.write('<span foreground="#2a2a2a">')
            output.write('—' * remainder)
            output.write('</span>')

        return output.getvalue()
