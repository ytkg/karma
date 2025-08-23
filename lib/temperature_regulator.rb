# 現在の値と目標値を比較し、エアコンの設定温度を調整する責務を持つクラス
class TemperatureRegulator
  ALLOWABLE_RANGE = 0.2
  MIN_SET_TEMPERATURE = 18
  MAX_SET_TEMPERATURE = 30

  def initialize(target_value)
    @target_value = target_value
  end

  def regulate(current_value:, previous_value:, previous_set_temperature:)
    if should_lower_temperature?(current_value, previous_value)
      new_temperature = (previous_set_temperature - 1).clamp(MIN_SET_TEMPERATURE, MAX_SET_TEMPERATURE)
      reason = if new_temperature == previous_set_temperature
                 :at_min_limit
               else
                 :lowered
               end
      return { temperature: new_temperature, reason: reason }
    end

    if should_raise_temperature?(current_value, previous_value)
      new_temperature = (previous_set_temperature + 1).clamp(MIN_SET_TEMPERATURE, MAX_SET_TEMPERATURE)
      reason = if new_temperature == previous_set_temperature
                 :at_max_limit
               else
                 :raised
               end
      return { temperature: new_temperature, reason: reason }
    end

    reason = if !higher_than_target?(current_value) && !lower_than_target?(current_value)
               :in_range
             else
               :improving_trend
             end

    { temperature: previous_set_temperature, reason: reason }
  end

  private

  def higher_than_target?(value)
    value >= @target_value + ALLOWABLE_RANGE
  end

  def should_lower_temperature?(current_value, previous_value)
    higher_than_target?(current_value) && is_trend_unfavorable?(current_value, previous_value)
  end

  def lower_than_target?(value)
    value <= @target_value - ALLOWABLE_RANGE
  end

  def should_raise_temperature?(current_value, previous_value)
    lower_than_target?(current_value) && is_trend_unfavorable?(current_value, previous_value)
  end

  def is_trend_unfavorable?(current_value, previous_value)
    (current_value - @target_value).abs >= (previous_value - @target_value).abs
  end
end
