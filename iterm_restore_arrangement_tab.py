#!/usr/bin/env python3

import iterm2
import sys

async def main(connection):
    await iterm2.Arrangement.async_restore(connection, sys.argv[1])

iterm2.run_until_complete(main)
