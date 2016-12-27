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
        self._cmd = cmd
        self._proc = None
        self._coro = create_subprocess_exec(
            *split(cmd), **kwargs, stdout=PIPE)

    @property
    def proc(self):
        if self._proc is not None:
            return self._proc
        else:
            raise RuntimeError(f'{self!r} was never awaited!')

    def __await__(self):
        if not self._proc:
            self._proc = yield from self._coro
        return self

    def __aiter__(self):
        return self

    async def __anext__(self):
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

    def __repr__(self):
        return f'<AIOPopen({self._cmd!r})>'


def mkbar(value):
    value = max(min(value, 100), 0)
    value = round(value / 100 * 16)
    remainder = 16 - value

    with StringIO() as output:
        if value > 0:
            # output.write('<b>')
            output.write('█' * value)
            # output.write('</b>')
        if remainder > 0:
            # output.write('<span foreground="#2a2a2a">')
            output.write('░' * remainder)
            # output.write('</span>')

        return output.getvalue()
