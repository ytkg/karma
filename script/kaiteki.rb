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

am = Ambient.new('93486', write_key: Hitoku.ambient_write_key, read_key: Hitoku.ambient_read_key)
last_data = am.read().last

aircon = client.device('02-202103110155-72537419')
set_temperature = last_data[:d4]

if temperature >= 24.2
  set_temperature -= 1
  aircon.commands(command: 'setAll', parameter: "#{set_temperature},2,1,on", command_type: 'command')
end

if temperature <= 23.8
  set_temperature += 1
  aircon.commands(command: 'setAll', parameter: "#{set_temperature},2,1,on", command_type: 'command')
end

am.send(d1: temperature, d2: humidity, d3: discomfort_index, d4: set_temperature)
