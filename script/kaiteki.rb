require 'hitoku'
require 'switchbot'

client = Switchbot::Client.new(Hitoku.switchbot_api_token, Hitoku.switchbot_api_secret)

device = client.device('B0E9FE5580EE')
status = device.status
temperature = status[:body][:temperature]
p "Current temperature: #{temperature}°C"

aircon = client.device('02-202103110155-72537419')
if temperature >= 24.3
  aircon.commands(command: 'setAll', parameter: '27,2,1,on', command_type: 'command')
end

if temperature <= 23.7
  aircon.commands(command: 'setAll', parameter: '29,2,1,on', command_type: 'command')
end
