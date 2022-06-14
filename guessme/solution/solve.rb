require 'httparty'
require 'yaml'

TARGET = ARGV[0] || 'http://localhost:9999'
if TARGET[-1] != '/'
  TARGET.concat('/')
end
EXPECTED_FLAG = YAML::load(File.read('../metadata.yml'))['flag']

puts "This is a lazy solution, so it's going to loop till it works. See you later!"
puts

loop do
  question = HTTParty.get("#{ TARGET }clue").parsed_response
  token = question['token']

  puts "Received token: #{ token }"
  puts "Sending wrong answer"


  response = HTTParty.post(
    "#{ TARGET }check",
    :body => {
      'token' => token,
      'guess' => 'no idea!',
    }.to_json,
    :headers => {
      'Content-Type' => 'application/json',
    },
  ).parsed_response

  if response['error']
    puts "Server returned an error (this is probably fine unless it always happens): #{ response['error'] }"
    sleep 2
    next
  end

  correct_answer = response['message'].gsub(/.*answer was /, '')

  puts "Correct answer: #{ correct_answer }"

  puts "Tweaking the last character of the token"
  last_char = token.length - 1
  while token[last_char] == '='
    last_char -= 1
  end
  token[last_char] = (token[last_char].ord ^ 1).chr
  puts "Updated token: #{ token }"

  result = HTTParty.post(
    "#{ TARGET }check",
    :body => {
      'token' => token,
      'guess' => correct_answer,
    }.to_json,
    :headers => {
      'Content-Type' => 'application/json',
    },
  ).parsed_response

  if result['result']
    puts "Result: #{ result['message'] }"
    if result['message'].include?(EXPECTED_FLAG)
      puts "Success!"
      exit 0
    else
      puts "Uh oh, the flag didn't look right!"
      exit 1
    end
  else
    puts "Trying again..."
  end
end

# We should never get here, but just in case
exit 1
