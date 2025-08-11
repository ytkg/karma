# frozen_string_literal: true

require 'hitoku'
require_relative '../mock'
require 'switchbot'
require_relative '../metrics/discomfort_index'
require_relative '../metrics/misnar_feeling_temperature'

class Kaiteki
  # 温度計（Meter）として、現在のメトリクスを取得する責務を持つクラス
  class Meter
    THERMOMETER_DEVICE_ID = 'B0E9FE5580EE'

    # @return [Hash] 現在のメトリクス
    def fetch_metrics
      status = switchbot_client.device(THERMOMETER_DEVICE_ID).status

      temperature = status[:body][:temperature]
      humidity = status[:body][:humidity]
      discomfort_index = ::Metrics::DiscomfortIndex.calculate(temperature, humidity)
      misnar_feeling_temperature = ::Metrics::MisnarFeelingTemperature.calculate(temperature, humidity)

      { temperature:, humidity:, discomfort_index:, misnar_feeling_temperature: }
    end

    private

    def switchbot_client
      @switchbot_client ||= Switchbot::Client.new(Hitoku.switchbot_api_token, Hitoku.switchbot_api_secret)
    end
  end
end
