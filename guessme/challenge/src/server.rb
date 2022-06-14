require 'json'
require 'openssl'
require 'securerandom'
require 'sinatra'
require 'set'

set :bind, ENV['HOST'] || '0.0.0.0'
set :port, ENV['PORT'] || '9999'
set :public_folder, 'public'

ALGORITHM      = 'aes-128-ctr'
KEY            = SecureRandom.random_bytes(16)
SIGNING_SECRET = SecureRandom.random_bytes(16)
IV_LENGTH      = 16

USED_WORDS = Set.new()
DICTIONARY = File.read('wordlist.txt').split(/\n/).shuffle()   # Shuffle for no real reason
ADJECTIVES = File.read('adjectives.txt').split(/\n/).shuffle() # Also shuffle for no real reason



get "/" do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/clue' do
  content_type 'application/json'

  token = SecureRandom.bytes(4).bytes.map { |b| DICTIONARY[b % DICTIONARY.length] }.join(' ')
  iv = SecureRandom.random_bytes(IV_LENGTH)
  clue = ADJECTIVES.sample(3)
  clue = "#{ clue[0] }, #{ clue[1] }, #{ ['or', 'and'].sample } #{ clue[2] }".capitalize

  cipher           = OpenSSL::Cipher.new(ALGORITHM).encrypt
  cipher.key       = KEY
  cipher.iv        = iv
  iv_and_encrypted = iv + cipher.update(token) + cipher.final

  hmac = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), SIGNING_SECRET, iv_and_encrypted)

  return {
    'token' => Base64::strict_encode64(hmac + iv_and_encrypted),
    'clue' => clue,
  }.to_json
end

post '/check' do
  content_type 'application/json'

  # Parse the data
  data = JSON.parse(request.body.read)

  # Remove whitespace
  data['token'].gsub!(/\s+/, '')

  # Valid base64 only
  if data['token'] !~ /^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$/
    return { 'error' => 'invalid_token' }.to_json
  end

  # Make sure they aren't re-guessing something
  if USED_WORDS.include?(data['token'])
    return { 'error' => 'already_used' }.to_json
  end

  # Validate the HMAC
  hmac, iv_and_encrypted = Base64::decode64(data['token']).unpack('A20A*')
  if hmac != OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), SIGNING_SECRET, iv_and_encrypted)
    return { 'error' => 'bad_signature' }.to_json
  end

  # Mark the token as used
  USED_WORDS.add(data['token'])

  # Decrypt
  iv, encrypted = iv_and_encrypted.unpack("A#{ IV_LENGTH }A*")
  cipher           = OpenSSL::Cipher.new(ALGORITHM).decrypt
  cipher.key       = KEY
  cipher.iv        = iv
  decrypted        = cipher.update(encrypted) + cipher.final

  if data['guess'] == decrypted
    return {
      'result'  => true,
      'message' => "Congratulations! #{ File.read('flag.txt') }",
    }.to_json
  else
    return {
      'result'  => false,
      'message' => "Sorry! The answer was #{ decrypted }",
    }.to_json
  end
end
