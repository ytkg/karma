# frozen_string_literal: true

class Kaiteki
  # Kaitekiクラスで利用するコメントを生成する責務を持つクラス
  class CommentBuilder
    def initialize(reason:, feeling_temperature:, new_set_temperature:)
      @reason = reason
      @feeling_temperature = feeling_temperature
      @new_set_temperature = new_set_temperature
    end

    def build
      case @reason
      when :lowered, :raised
        "体感温度が#{@feeling_temperature}°だったので、エアコンの設定温度を#{@new_set_temperature}°に変更しました"
      when :in_range
        "体感温度が#{@feeling_temperature}°で目標範囲内のため、エアコンの設定温度は変更しませんでした"
      when :improving_trend
        "体感温度が#{@feeling_temperature}°で改善傾向のため、エアコンの設定温度は変更しませんでした"
      when :at_min_limit
        "設定温度が下限のため、エアコンの設定温度は変更しませんでした"
      when :at_max_limit
        "設定温度が上限のため、エアコンの設定温度は変更しませんでした"
      end
    end
  end
end
