require_relative '../lib/temperature_regulator'
require_relative '../lib/kaiteki/metrics_repository'
require_relative '../lib/kaiteki/meter'
require_relative '../lib/kaiteki/air_conditioner'

# 複数のサービスクラスを協調させ、快適な温度を維持するためのビジネスロジックを実行するクラス
class Kaiteki
  BASE_TEMPERATURE = 28

  def initialize(target_temperature = 24)
    @target_temperature = target_temperature
  end

  def execute
    current_metrics = meter.fetch_metrics
    current_metrics.each { |name, value| p "Current #{name}: #{value}" }

    if air_conditioner.off?
      metrics_repository.send(current_metrics.merge(set_temperature: 0))
      return
    end

    previous_metrics = metrics_repository.read_latest
    previous_set_temperature = previous_metrics[:set_temperature]

    initial_set_temperature = previous_set_temperature.zero? ? BASE_TEMPERATURE : previous_set_temperature

    new_set_temperature = temperature_regulator.regulate(
      current_value: current_metrics[:misnar_feeling_temperature],
      previous_value: previous_metrics[:misnar_feeling_temperature],
      previous_set_temperature: initial_set_temperature
    )

    feeling_temperature = current_metrics[:misnar_feeling_temperature]

    comment = if new_set_temperature != initial_set_temperature
                air_conditioner.set_temperature(new_set_temperature)
                "体感温度が#{feeling_temperature}°だったので、エアコンの設定温度を#{new_set_temperature}°に変更しました"
              else
                "体感温度が#{feeling_temperature}°だったため、エアコンの設定温度は変更しませんでした"
              end

    metrics_repository.send(
      current_metrics.merge(set_temperature: new_set_temperature),
      comment: comment
    )
  end

  private

  def metrics_repository
    @metrics_repository ||= Kaiteki::MetricsRepository.new
  end

  def meter
    @meter ||= Kaiteki::Meter.new
  end

  def air_conditioner
    @air_conditioner ||= Kaiteki::AirConditioner.new
  end

  def temperature_regulator
    @temperature_regulator ||= TemperatureRegulator.new(@target_temperature)
  end
end
