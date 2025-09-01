require_relative '../app/kaiteki'

Kaiteki.new(23.5).execute

puts '5分後に再度実行します'
sleep 300

Kaiteki.new(23.5).execute
