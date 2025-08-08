require 'hitoku'
require 'switchbot'
require 'ruby-ambient'

class Kaiteki
  BASE_TEMPERATURE = 28
  TARGET_TEMPERATURE = 24
  ALLOWABLE_RANGE = 0.2

  def initialize(switchbot_client:, ambient_client:, options: {})
    @switchbot_client = switchbot_client
    @ambient_client = ambient_client
    @aircon_id = options[:aircon_id]
    @meter_id = options[:meter_id]
    @plug_id = options[:plug_id]
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

    set_temperature = previous_metrics[:set_temperature].zero? ? BASE_TEMPERATURE : previous_metrics[:set_temperature]

    if should_lower_temperature?(current_metrics[:temperature], previous_metrics[:temperature])
      set_temperature = (set_temperature - 1).clamp(18, 30)
      set_the_temperature(set_temperature)
    end

    if should_raise_temperature?(current_metrics[:temperature], previous_metrics[:temperature])
      set_temperature = (set_temperature + 1).clamp(18, 30)
      set_the_temperature(set_temperature)
    end

    send_metrics(current_metrics.merge(set_temperature:))
  end

  private

  attr_reader :switchbot_client, :ambient_client, :aircon_id, :meter_id, :plug_id

  def aircon_off?
    device = switchbot_client.device(plug_id)
    status = device.status

    status[:body][:weight] < 10
  end

  def calculate_discomfort_index(temperature, humidity)
    0.81 * temperature + humidity * 0.01 * (0.99 * temperature - 14.3) + 46.3
  end

  def fetch_current_metrics
    device = switchbot_client.device(meter_id)
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

  def higher_than_target?(temperature)
    temperature >= TARGET_TEMPERATURE + ALLOWABLE_RANGE
  end

  def should_lower_temperature?(current_temperature, previous_temperature)
    higher_than_target?(current_temperature) && previous_temperature <= current_temperature
  end

  def lower_than_target?(temperature)
    temperature <= TARGET_TEMPERATURE - ALLOWABLE_RANGE
  end

  def should_raise_temperature?(current_temperature, previous_temperature)
    lower_than_target?(current_temperature) && previous_temperature >= current_temperature
  end

  def set_the_temperature(temperature)
    if development?
      puts "Set the temperature: #{temperature}"

      return
    end

    aircon = switchbot_client.device(aircon_id)
    aircon.commands(command: 'setAll', parameter: "#{temperature},2,1,on", command_type: 'command')
  end

  def send_metrics(metrics)
    if development?
      puts "Send metrics: #{metrics}"

      return
    end

    ambient_client.send(d1: metrics[:temperature], d2: metrics[:humidity], d3: metrics[:discomfort_index], d4: metrics[:set_temperature])
  end

  def development?
    ENV.fetch('KARMA_ENV', nil) == 'development'
  end
end
