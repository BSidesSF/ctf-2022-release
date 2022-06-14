A Windows reversing table that takes advantage of relocations to modify code
at runtime.

Basically, this does some math with a seed. But the trick is, the seed is marked,
in the PE file (.exe), as an absolute memory address. When Windows tries to load
it, the program is re-based by ASLR and the seed is changed proportionally. The
user needs to leak a memory address, then use that to calculate the ACTUAL seed.
I think this is pretty cruel. :)
