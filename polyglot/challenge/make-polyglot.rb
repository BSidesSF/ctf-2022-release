puts "Make sure Release/polyglot.exe is the built version you want! That requires.... Windows!"
puts ""
ORIGINAL = File.read("Release/polyglot.exe").force_encoding('ASCII-8BIT')

puts "Building stub..."
system("nasm -fbin -o stub stub.asm")
puts
STUB = File.read('stub').force_encoding('ASCII-8BIT')

START_OFFSET = 0x40
END_OFFSET = ORIGINAL[0x3c..].unpack('V').pop

puts "Start = 0x%x, end = 0x%x" % [START_OFFSET, END_OFFSET]

if STUB.length > (END_OFFSET - START_OFFSET - 1)
  puts "Stub is too big! Length = %d, max = %d" % [STUB.length, END_OFFSET - START_OFFSET]
  exit
end

File.write("polyglot.exe", [
  ORIGINAL[0..0x40],
  STUB,
  ORIGINAL[END_OFFSET..]
].pack("a*A#{ END_OFFSET - START_OFFSET - 1}a*"))
