#!/usr/bin/env python3

import iterm2
from json import dumps

async def main(connection):
    connections = await iterm2.Arrangement.async_list(connection)
    items = []

    for i in connections:
      items.append({ 'arg': i, 'title': i })

    print(dumps({ 'items': items }))

iterm2.run_until_complete(main)
