require_relative '../app/kaiteki'

TEMP = 23.2

Kaiteki.new(TEMP).execute

puts '5分後に再度実行します'
sleep 300

Kaiteki.new(TEMP).execute
