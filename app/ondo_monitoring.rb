require 'hitoku'
require 'switchbot'
require 'ruby-ambient'
require_relative '../lib/metrics/discomfort_index'
require_relative '../lib/metrics/misnar_feeling_temperature'
require_relative '../lib/mock'

class OndoMonitoring
  DEVICE_IDS = %w[B0E9FE5580EE E3F7060488E0].freeze

  def execute
    metrics = DEVICE_IDS.map { |device_id| fetch_metrics(device_id) }

    ambient_client.send(
      d1: metrics[0][:temperature], d2: metrics[0][:humidity], d3: metrics[0][:discomfort_index], d4: metrics[0][:misnar_feeling_temperature],
      d5: metrics[1][:temperature], d6: metrics[1][:humidity], d7: metrics[1][:discomfort_index], d8: metrics[1][:misnar_feeling_temperature]
    )
  end

  private

  def fetch_metrics(device_id)
    status = switchbot_client.device(device_id).status
    temperature = status[:body][:temperature]
    humidity = status[:body][:humidity]

    {
      temperature:,
      humidity:,
      discomfort_index: Metrics::DiscomfortIndex.calculate(temperature, humidity),
      misnar_feeling_temperature: Metrics::MisnarFeelingTemperature.calculate(temperature, humidity)
    }
  end

  def switchbot_client
    @switchbot_client ||= Switchbot::Client.new(Hitoku.switchbot_api_token, Hitoku.switchbot_api_secret)
  end

  def ambient_client
    @ambient_client ||= Ambient.new('93505', write_key: Hitoku.ambient_monitoring_write_key)
  end
end
