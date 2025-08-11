require 'hitoku'
require 'switchbot'
require 'ruby-ambient'
require_relative '../lib/metrics/discomfort_index'
require_relative '../lib/metrics/misnar_feeling_temperature'
require_relative '../lib/mock'
require_relative '../lib/temperature_regulator'

class Kaiteki
  BASE_TEMPERATURE = 28

  def initialize(target_temperature = 24)
    @target_temperature = target_temperature
  end

  def execute
    current_metrics = fetch_current_metrics

    current_metrics.each do |name, value|
      p "Current #{name}: #{value}"
    end

    if aircon_off?
      send_metrics(current_metrics.merge(set_temperature: 0))

      return
    end

    previous_metrics = fetch_previous_metrics
    previous_set_temperature = previous_metrics[:set_temperature]

    initial_set_temperature = previous_set_temperature.zero? ? BASE_TEMPERATURE : previous_set_temperature

    new_set_temperature = temperature_regulator.regulate(
      current_temperature: current_metrics[:temperature],
      previous_temperature: previous_metrics[:temperature],
      previous_set_temperature: initial_set_temperature
    )

    if new_set_temperature != initial_set_temperature
      set_the_temperature(new_set_temperature)
    end

    send_metrics(current_metrics.merge(set_temperature: new_set_temperature))
  end

  private

  def aircon_off?
    device = switchbot_client.device('D83BDA170B26')
    status = device.status

    status[:body][:weight] < 10
  end

  def switchbot_client
    @switchbot_client ||= Switchbot::Client.new(Hitoku.switchbot_api_token, Hitoku.switchbot_api_secret)
  end

  def ambient_client
    @ambient_client ||= Ambient.new('93486', write_key: Hitoku.ambient_write_key, read_key: Hitoku.ambient_read_key)
  end

  def fetch_current_metrics
    device = switchbot_client.device('B0E9FE5580EE')
    status = device.status

    temperature = status[:body][:temperature]
    humidity = status[:body][:humidity]
    discomfort_index = Metrics::DiscomfortIndex.calculate(temperature, humidity)
    misnar_feeling_temperature = Metrics::MisnarFeelingTemperature.calculate(temperature, humidity)

    { temperature:, humidity:, discomfort_index:, misnar_feeling_temperature: }
  end

  def fetch_previous_metrics
    metrics = ambient_client.read.last

    {
      temperature: metrics[:d1],
      humidity: metrics[:d2],
      discomfort_index: metrics[:d3],
      set_temperature: metrics[:d4],
      misnar_feeling_temperature: metrics[:d5]
    }
  end

  def temperature_regulator
    @temperature_regulator ||= TemperatureRegulator.new(@target_temperature)
  end

  def set_the_temperature(temperature)
    if development?
      puts "Set the temperature: #{temperature}"

      return
    end

    aircon = switchbot_client.device('02-202103110155-72537419')
    aircon.commands(command: 'setAll', parameter: "#{temperature},2,1,on", command_type: 'command')
  end

  def send_metrics(metrics)
    if development?
      puts "Send metrics: #{metrics}"

      return
    end

    ambient_client.send(d1: metrics[:temperature], d2: metrics[:humidity], d3: metrics[:discomfort_index], d4: metrics[:set_temperature], d5: metrics[:misnar_feeling_temperature])
  end

  def development?
    ENV.fetch('KARMA_ENV', nil) == 'development'
  end
end
