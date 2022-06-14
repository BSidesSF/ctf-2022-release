require 'httparty'
require 'date'
require 'pp'

METADATA = YAML::load(File.read('../metadata.yml'))
EXPECTED_FLAG = METADATA['flag']
DEFAULT_PORT = METADATA['port']

date = Date.today
TARGET = ARGV[0] || "http://localhost:#{ DEFAULT_PORT }/"
if TARGET[-1] != '/'
  TARGET.concat('/')
end

# Get the session token
COOKIES = HTTParty::CookieHash.new

def go(date, fudge)
  clone_date = Date.new(date.year - 100, date.month, date.day)
  difference = (Date.today - clone_date + fudge).to_i

  solution = HTTParty.get("#{TARGET}past/#{difference}").parsed_response
  return HTTParty.post(
    "#{TARGET}submit",
    :body => {
      'date' => date.to_s,
      'path' => solution,
    }.to_json,
    :headers => {
      "Content-Type" => "application/json",
      'Cookie' => COOKIES.to_cookie_string,
    },
  )
end

puts "Trying to figure out the exact fudge factor..."
-5.upto(5) do |i|
  puts " -> Testing %d..." % i
  test = go(date, i)
  puts test
  if test.parsed_response['wrongness'] == 0
    puts "Found the fudge factor: #{ i }"
    FUDGE = i
    break
  end
end

if !Object.const_defined?(:FUDGE)
  puts "Couldn't find a working this-day solution!"
  exit 1
end


0.upto(35) do
  date = date + 1

  # Get a past date to clone
  response = go(date, FUDGE)
  pp response.headers
  puts response
  puts

  if !response.get_fields('set-cookie')
    puts "Uh oh, we may have failed:"
    puts response

    exit
  end
  response.get_fields('set-cookie').each { |c| COOKIES.add_cookies(c) }

  if response.parsed_response['results'] && response.parsed_response['results']['flag']
    pp response.parsed_response

    if response.parsed_response['results']['flag'].include?(EXPECTED_FLAG)
      puts "Success!"
      exit 0
    else
      puts "We got a flag, but it was the wrong one!"
      exit 1
    end
  end
end

puts "Hmm, no flag ever showed up!"
exit 1
