Notes on solving:

break in getfib():

saved rip = 0x555555555354
rip at 0x7ffffff7d358
$1 = (struct fibcache *) 0x7ffffff7d380

0x28 (40)
so -4? (results in -5, aka -40 bytes)
works for me :)

saved rip: -4
stack cookie: -6 (0xeb4a4ef994d4d500)

ooh, a return address into atoi is still on stack, does it survive long enough?
-12

It does not.

Added a local function to make it a bit easier on players.

buf: 0x7fffffffd390
stack cookie: 0x7fffffffd498
buf +0x108 == 264 bytes

