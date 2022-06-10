#QUIET = true
require '../challenge/src/app.rb'

LEVELS.each do |l|
  begin
    puts "# Testing #{ l['name'] }..."
    gogogo(l, assemble(l['solution']))
    puts "--> w00t!"
  rescue StandardError => e
    puts "--> solution threw an error: #{ e }"
    puts e.backtrace
    exit
  end
end

puts "Should probably verify these are sensible:"
puts
LEVELS.each do |l|

  w '---'
  w
  w "  Name: `#{ l['name'] }`"
  w "  Completion: `#{ l['completion'] || 'n/a' }`"
  w "  Flag (only on last): `#{ l['flag'] || 'n/a' }`"
  w "  Password (except on first): `#{ l['password'] || 'n/a' }`"
  w
end
exit
