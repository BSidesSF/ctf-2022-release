#!/usr/bin/ruby

### Hello, nosy players!
###
### This is the script that powers shurdles! If you're reading this, it means
### you bypassed the challenges and popped a shell. That's okay!
###
### You can get the flags and solutions in the YAML files, if you want them!

require 'json'
require 'yaml'
require 'tty-markdown'
require 'metasm'

COLOR = ARGV[0] == '0' ? :never : :always
DIR = __dir__ || File.dirname(__FILE__)

def w(s='', **args)
  text = TTY::Markdown.parse(
    s,
    width: 80,
    color: COLOR,
    symbols: {
      base: :ascii,
      override: {
        lsquo: "'",
        rsquo: "'"
      }
    },
    **args
  )

  puts text
  $stdout.flush()
end

def assemble(code)
  w "Assembling with: `Metasm::Shellcode.assemble(Metasm::AMD64.new, code)`..."
  return Metasm::Shellcode.assemble(Metasm::AMD64.new, code).encoded.data.unpack('H*').pop
end

def gogogo(level, code)
  if code !~ /^([0-9a-f][0-9a-f])+$/
    raise "Somehow, non-hex code got to gogogo() function. Please don't do that!"
  end

  if level['filter']
    data = [code].pack('H*')
    eval(level['filter'])
  end

  json = `#{ DIR }/mandrake code --harness=#{ DIR }/harness #{ code }`
  begin
    result = JSON::parse(json)
  rescue JSON::ParserError => e
    puts "Uh oh, an internal error happened - we could not parse the JSON we got from our tooling:"
    puts
    puts json
    puts
    puts "Error message: #{ e }"
    puts
    puts "This is probably something that you should escalate, unless you're breaking it on purpose :)"
  end

  w
  w
  w
  w
  w '---'
  w '# Results'
  w '---'

  if result['stdout'] && result['stdout'].length > 0
    w "Stdout: #{ result['stdout'] }"
  elsif result['stderr'] && result['stderr'].length > 0
    w "Stderr: #{ result['stderr'] }"
  end
  w result['exit_reason']
  w '---'

  w "Here's how your code ran:"
  result['history'].each do |h|
    puts
    puts ' rax = %08x | rbx = %08x | rcx = %08x | rdx = %08x' % [h['rax']['value'], h['rbx']['value'], h['rcx']['value'], h['rdx']['value']]
    puts ' rsi = %08x | rdi = %08x | rbp = %08x | rsp = %08x' % [h['rsi']['value'], h['rdi']['value'], h['rbp']['value'], h['rsp']['value']]
    puts
    puts '0x%08x %s' % [h['rip']['value'], h['rip']['as_instruction']]
    if !h['rip']['extra'].nil?
      h['rip']['extra'].each do |x|
        print "    -> "
        w x
      end
    end
  end
  puts

  eval(level['checker'])

  return true
end

LEVELS = []
i = 0
loop do
  filename = "#{ DIR }/level#{i}.yaml"
  if !File.exist?(filename)
    break
  end

  #w "Loading #{ filename }..."
  data = {
    index: i,
  }.merge(YAML::load_file(filename))

  LEVELS[i] = data
  i += 1
end

def go(level)
  w
  w
  w
  w
  w '---'
  w
  w "# #{ level['name'] }"
  w "(Password to skip directly here: `#{ level['password'].length > 0 ? level['password'] : 'n/a' }`)"
  w
  w '---'
  w
  w level['text']
  w
  w '---'
  w
  w 'Your code:'
  w

  first_line = true
  code = []
  loop do
    line = gets()
    if line.nil?
      w "Disconnected"
      exit
    end

    line.chomp!()
    line.lstrip!()
    if first_line && line =~ /^([0-9a-f][0-9a-f])+$/
      return gogogo(level, line)
    end

    if line == '.'
      begin
        code = assemble(code.join("\n"))
        w("Assembles to: #{ code }", width: 99999)
        sleep(1)
        return gogogo(level, code)
      rescue StandardError => e
        w
        w
        w
        w '---'
        w
        w '# Uh oh, something is wrong with your code:'
        w
        w "*#{ e }*"
        w
        w '---'
        w 'Press &lt;enter&gt; to start over!'
        gets

        return false
      end
    end

    first_line = false
    code << line
  end
end

if $0 == __FILE__
  level_no = nil
  loop do
    w "Enter password to skip to a level, or just press &lt;enter&gt; to start from"
    w "the beginning:"
    w

    password = gets()
    exit if password.nil?

    level_no = LEVELS.index { |i| i['password'] == password.chomp() }

    if !level_no.nil?
      break
    end
    w "Uh oh, that password didn't match a level!"
    w "Reminder: just hit &lt;enter&gt; to start from the beginning"
    w
  end

  loop do
    level = LEVELS[level_no]

    if go(level)
      w '---'
      w level['completion']

      if level['flag']
        w '---'
        w
        w "Wow, you've earned a flag: `#{ level['flag'] }`"
        0.upto(2) do
          w '.'
          sleep(1)
        end
        w
        w "Good luck on future challenges!"
        exit
      end

      w '---'
      w 'Press &lt;enter&gt; to continue'
      gets
      level_no += 1
    end
  end
end
