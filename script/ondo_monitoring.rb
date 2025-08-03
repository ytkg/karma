require 'hitoku'
require 'switchbot'
require 'ruby-ambient'

def calculate_discomfort_index(temperature, humidity)
  (0.81 * temperature + humidity * 0.01 * (0.99 * temperature - 14.3) + 46.3).round(1)
end

def misnar_feeling_temperature(temperature, humidity)
  (37 - ((37 - temperature) / (1.24828 - 0.0014 * humidity)) - 0.29 * temperature * (1 - humidity / 100.0)).round(1)
end

def fetch_metrics(device_id)
  client = Switchbot::Client.new(Hitoku.switchbot_api_token, Hitoku.switchbot_api_secret)
  status = client.device(device_id).status
  temperature = status[:body][:temperature]
  humidity = status[:body][:humidity]

  {
    temperature:,
    humidity:,
    discomfort_index: calculate_discomfort_index(temperature, humidity),
    misnar_feeling_temperature: misnar_feeling_temperature(temperature, humidity)
  }
end

metrics1 = fetch_metrics('B0E9FE5580EE')
metrics2 = fetch_metrics('E3F7060488E0')

am = Ambient.new('93505', write_key: Hitoku.ambient_monitoring_write_key)
am.send(
  d1: metrics1[:temperature], d2: metrics1[:humidity], d3: metrics1[:discomfort_index], d4: metrics1[:misnar_feeling_temperature],
  d5: metrics2[:temperature], d6: metrics2[:humidity], d7: metrics2[:discomfort_index], d8: metrics2[:misnar_feeling_temperature],
)
