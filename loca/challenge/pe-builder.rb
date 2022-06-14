IN_FILE = "./src/Release/loca.exe"
OUT_FILE = "./loca.exe"

orig = File.read(IN_FILE).force_encoding('ASCII-8BIT')
PE = orig[0x3c..].unpack('V').pop

if orig[PE..(PE+1)] != 'PE'
  puts "Missing PE magic?"
  exit
end

NUMBER_OF_SEGMENTS = orig[PE+6..].unpack('v').pop
puts "Number of segments: #{ NUMBER_OF_SEGMENTS }"

# Figure out where we need to hack
RELOC_HACK = (`objdump -D #{ IN_FILE } | grep -i ABF25330 | cut -d\: -f1`.to_i(16) + 3) & 0x0000FFFF
puts "RELOC_HACK = %x" % RELOC_HACK
NEW_RELOCS = [
  { type: 3, offset: RELOC_HACK },
]

# Get the reloc size from the header
header_reloc_size = orig[(PE+0xa4)..].unpack('V').pop

# Get the reloc section
reloc_offset = PE + 0xf8 + ((NUMBER_OF_SEGMENTS - 1) * 40)
reloc_check = orig[reloc_offset..(reloc_offset+8)].unpack('Z*').pop
if reloc_check != '.reloc'
  puts "Last section isn't .reloc, it's #{ reloc_check }!"
  exit
end

virtual_size, virtual_address, raw_size, raw_address = orig[(reloc_offset + 8)..].unpack('VVVV')

puts "Reloc size (from header):             0x%08x" % header_reloc_size
puts "Reloc virtual size (from section):    0x%08x" % virtual_size
puts "Reloc virtual address (from section): 0x%08x" % virtual_address
puts "Reloc raw_size (from section):        0x%08x" % raw_size
puts "Reloc raw_address (from section):     0x%08x" % raw_address
puts

# Parse the existing relocs
puts "Breaking open reloc blocks..."
offset = 0
RELOCS = []
while offset < header_reloc_size
  reloc_block = orig[(raw_address + offset)..]
  page_rva, block_size = reloc_block.unpack('VV')
  puts "Block representing: 0x%08x" % page_rva
  puts "Block size: 0x%08x" % block_size

  if block_size == 0
    break
  end

  entries = reloc_block[8..].unpack("v#{(block_size - 8) / 2}")
  #puts entries.map { |e| '%04x' % e }

  # Do the changes
  for r in NEW_RELOCS do
    if r[:offset] & 0xFFFFF000 == page_rva
      entries << ((r[:type] << 12) | (r[:offset] & 0x0FFF))
    end
  end

  # Pad if needed
  if (entries.length % 4) != 0
    entries << 0
  end

  RELOCS << {
    page: page_rva,
    size: (entries.length * 2) + 8,
    entries: entries,
  }

  offset += block_size
  puts
end

# Build the new reloc string
puts "Building new reloc blocks..."
new_relocs = ''
for r in RELOCS do
  new_relocs.concat([r[:page], r[:size]].pack('VV'))
  new_relocs.concat(r[:entries].pack('v*'))
end

puts '%08x' % orig.length

# Replace the header size
orig[(PE+0xa4)..(PE+0xa4+3)] = [new_relocs.length].pack('V')

# Increase the virtual_size and raw_size proportionally
orig[(reloc_offset + 8)..(reloc_offset + 8 + 3)] = [(virtual_size - header_reloc_size + new_relocs.length)].pack('V')
#orig[(reloc_offset + 16)..(reloc_offset + 16 + 3)] = [(raw_size - header_reloc_size + new_relocs.length)].pack('V')

# Replace the old relocs
orig[raw_address..(raw_address + new_relocs.length - 1)] = new_relocs

puts '%08x' % orig.length
File.write(OUT_FILE, orig)
