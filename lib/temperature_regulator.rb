class TemperatureRegulator
  ALLOWABLE_RANGE = 0.2
  MIN_SET_TEMPERATURE = 18
  MAX_SET_TEMPERATURE = 30

  def initialize(target_temperature)
    @target_temperature = target_temperature
  end

  def regulate(current_temperature:, previous_temperature:, previous_set_temperature:)
    set_temperature = previous_set_temperature

    if should_lower_temperature?(current_temperature, previous_temperature)
      return (set_temperature - 1).clamp(MIN_SET_TEMPERATURE, MAX_SET_TEMPERATURE)
    end

    if should_raise_temperature?(current_temperature, previous_temperature)
      return (set_temperature + 1).clamp(MIN_SET_TEMPERATURE, MAX_SET_TEMPERATURE)
    end

    set_temperature
  end

  private

  def higher_than_target?(temperature)
    temperature >= @target_temperature + ALLOWABLE_RANGE
  end

  def should_lower_temperature?(current_temperature, previous_temperature)
    higher_than_target?(current_temperature) && is_trend_unfavorable?(current_temperature, previous_temperature)
  end

  def lower_than_target?(temperature)
    temperature <= @target_temperature - ALLOWABLE_RANGE
  end

  def should_raise_temperature?(current_temperature, previous_temperature)
    lower_than_target?(current_temperature) && is_trend_unfavorable?(current_temperature, previous_temperature)
  end

  def is_trend_unfavorable?(current_temp, prev_temp)
    (current_temp - @target_temperature).abs >= (prev_temp - @target_temperature).abs
  end
end
