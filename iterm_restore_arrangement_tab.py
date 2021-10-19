#!/usr/bin/env python3

import iterm2
import sys

async def main(connection):
    app = await iterm2.async_get_app(connection)
    window = app.current_terminal_window

    await iterm2.Arrangement.async_restore(connection, sys.argv[1], window.window_id)
    await window.async_activate()

iterm2.run_until_complete(main)
