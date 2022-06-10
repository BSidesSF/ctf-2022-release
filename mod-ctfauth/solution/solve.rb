require 'httparty'
require 'digest'
require 'base64'

TARGET = String::new(ARGV[0]) || 'http://localhost:4444'
if TARGET[-1] != '/'
  TARGET.concat('/')
end
TARGET.concat('secret/secret.html')

METADATA = YAML::load(File.read('../metadata.yml'))
EXPECTED_FLAG = METADATA['flag']

# These are from the binary
USERNAME = 'ctf'
SECRET = 'GuardingTheGatesFromEvilCTFPlayers'

md5 = Digest::MD5.new()
md5.update(SECRET)
md5.update(USERNAME)
md5.update(SECRET)
RAW_AUTH_TOKEN = md5.digest()

puts "Making sure we can't bypass..."

if HTTParty.get(TARGET).parsed_response.include?(EXPECTED_FLAG)
  puts "Got the flag without headers!"
  exit 1
end

if HTTParty.get(
  TARGET, {
    headers: {
      'X-CTF-Authorization' => "Token #{ Base64::strict_encode64(RAW_AUTH_TOKEN) }"
    }
  }
).parsed_response.include?(EXPECTED_FLAG)
  puts "Got the flag without a username!"
  exit 1
end


if HTTParty.get(
  TARGET, {
    headers: {
      'X-CTF-User' => 'ctf',
      #'X-CTF-Authorization' => "Token #{ Base64::strict_encode64(RAW_AUTH_TOKEN) }"
    }
  }
).parsed_response.include?(EXPECTED_FLAG)
  puts "Got the flag without a token!"
  exit 1
end

puts
puts "Testing with correct authorization..."
response = HTTParty.get(
  TARGET, {
    headers: {
      'X-CTF-User' => 'ctf',
      'X-CTF-Authorization' => "Token #{ Base64::strict_encode64(RAW_AUTH_TOKEN) }"
    }
  }
).parsed_response

puts "Response:"
puts response
puts

if(response.include?(EXPECTED_FLAG))
  puts "Success!"
  exit 0
end

puts "Body didn't contain the flag!"
exit 1
