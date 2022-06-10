require 'socket'
require '../challenge/src/app.rb'

METADATA = YAML::load(File.read('../metadata.yml'))
EXPECTED_FLAG = METADATA['flag']
DEFAULT_PORT = METADATA['port']

HOST = ARGV[0] || 'localhost'
PORT = (ARGV[1] || DEFAULT_PORT).to_i

def read_until(s, str)
  buffer = ''

  loop do
    c = s.read(1)
    print c
    buffer += c

    if buffer.include?(EXPECTED_FLAG)
      puts
      puts
      puts "Got the flag!"
      puts
      exit 0
    end

    if buffer.include?(str)
      return str
    end
  end
end

puts "Connecting to #{ HOST }:#{ PORT }"
s = TCPSocket::new(HOST, PORT)

read_until(s, "beginning:")
s.write("\n")

LEVELS.each do |level|
  read_until(s, "Your code:")

  puts
  puts "Sending solution for level \"#{ level['name'] }\"..."

  puts(level['solution'])
  s.write(level['solution'])
  s.write("\n.\n")

  read_until(s, 'to continue')
  s.write("\n")

end

puts "Apparently the flag never turned up? Sorry.."
exit 1
