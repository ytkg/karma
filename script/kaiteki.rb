require 'hitoku'
require 'switchbot'
require 'ruby-ambient'

client = Switchbot::Client.new(Hitoku.switchbot_api_token, Hitoku.switchbot_api_secret)

device = client.device('B0E9FE5580EE')
status = device.status

temperature = status[:body][:temperature]
p "Current temperature: #{temperature}°C"

humidity = status[:body][:humidity]
p "Current humidity: #{humidity}%"

discomfort_index = 0.81 * temperature + humidity * 0.01 * (0.99 * temperature - 14.3) + 46.3
p "Current discomfort_index: #{discomfort_index}"

aircon = client.device('02-202103110155-72537419')

set_temperature = 0
if temperature >= 24.3
  set_temperature = 27
  aircon.commands(command: 'setAll', parameter: "#{set_temperature},2,1,on", command_type: 'command')
end

if temperature <= 23.7
  set_temperature = 29
  aircon.commands(command: 'setAll', parameter: "#{set_temperature},2,1,on", command_type: 'command')
end

am = Ambient.new('93486', write_key: Hitoku.ambient_write_key)
am.send(d1: temperature, d2: humidity, d3: discomfort_index, d4: set_temperature)
