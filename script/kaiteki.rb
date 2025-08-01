require 'hitoku'
require 'switchbot'
require 'ruby-ambient'

class Kaiteki
  TARGET_TEMPERATURE = 24

  def execute
    current_metrics = fetch_current_metrics

    current_metrics.each do |name, value|
      p "Current #{name}: #{value}"
    end

    previous_metrics = fetch_previous_metrics

    aircon = switchbot_client.device('02-202103110155-72537419')
    set_temperature = previous_metrics[:set_temperature]

    if current_metrics[:temperature] >= TARGET_TEMPERATURE + 2
      set_temperature -= 1 if previous_metrics[:temperature] <= current_metrics[:temperature]
      aircon.commands(command: 'setAll', parameter: "#{set_temperature},2,1,on", command_type: 'command')
    end

    if current_metrics[:temperature] <= TARGET_TEMPERATURE - 2
      set_temperature += 1 if previous_metrics[:temperature] >= current_metrics[:temperature]
      aircon.commands(command: 'setAll', parameter: "#{set_temperature},2,1,on", command_type: 'command')
    end

    send_metrics(current_metrics.merge(set_temperature:))
  end

  private

  def switchbot_client
    @switchbot_client ||= Switchbot::Client.new(Hitoku.switchbot_api_token, Hitoku.switchbot_api_secret)
  end

  def ambient_client
    @ambient_client ||= Ambient.new('93486', write_key: Hitoku.ambient_write_key, read_key: Hitoku.ambient_read_key)
  end

  def calculate_discomfort_index(temperature, humidity)
    0.81 * temperature + humidity * 0.01 * (0.99 * temperature - 14.3) + 46.3
  end

  def fetch_current_metrics
    device = switchbot_client.device('B0E9FE5580EE')
    status = device.status

    temperature = status[:body][:temperature]
    humidity = status[:body][:humidity]
    discomfort_index = calculate_discomfort_index(temperature, humidity)

    { temperature:, humidity:, discomfort_index: }
  end

  def fetch_previous_metrics
    metrics = ambient_client.read.last

    {
      temperature: metrics[:d1],
      humidity: metrics[:d2],
      discomfort_index: metrics[:d3],
      set_temperature: metrics[:d4]
    }
  end

  def send_metrics(metrics)
    ambient_client.send(d1: metrics[:temperature], d2: metrics[:humidity], d3: metrics[:discomfort_index], d4: metrics[:set_temperature])
  end
end

Kaiteki.new.execute
