require_relative '../../lib/temperature_regulator'

describe TemperatureRegulator do
  describe '#regulate' do
    subject(:regulate) do
      described_class.new(target_value).regulate(
        current_value: current_value,
        previous_value: previous_value,
        previous_set_temperature: previous_set_temperature
      )
    end

    let(:target_value) { 24 }
    let(:previous_set_temperature) { 25 }

    context '値を下げるべき場合' do
      # 現在(24.3)が目標(24) + 許容範囲(0.2)より高く、
      # かつ現在(24.3)が前回(24.2)より高い
      let(:current_value) { 24.3 }
      let(:previous_value) { 24.2 }

      it '1度下げた温度と理由を返す' do
        expect(regulate).to eq({ temperature: 24, reason: :lowered })
      end
    end

    context '値を上げるべき場合' do
      # 現在(23.7)が目標(24) - 許容範囲(0.2)より低く、
      # かつ現在(23.7)が前回(23.8)より低い
      let(:current_value) { 23.7 }
      let(:previous_value) { 23.8 }

      it '1度上げた温度と理由を返す' do
        expect(regulate).to eq({ temperature: 26, reason: :raised })
      end
    end

    context '目標範囲内の場合' do
      # 現在(24.1)が目標(24) +/- 許容範囲(0.2)の範囲内
      let(:current_value) { 24.1 }
      let(:previous_value) { 24.0 }

      it '前回と同じ設定温度と理由を返す' do
        expect(regulate).to eq({ temperature: previous_set_temperature, reason: :in_range })
      end
    end

    context '目標より値が高いが、下降傾向にある場合' do
      # 現在(24.3)が目標(24) + 許容範囲(0.2)より高いが、
      # 現在(24.3)が前回(24.4)より低い
      let(:current_value) { 24.3 }
      let(:previous_value) { 24.4 }

      it '前回と同じ設定温度と理由を返す' do
        expect(regulate).to eq({ temperature: previous_set_temperature, reason: :improving_trend })
      end
    end

    context '目標より値が低いが、上昇傾向にある場合' do
      # 現在(23.7)が目標(24) - 許容範囲(0.2)より低いが、
      # 現在(23.7)が前回(23.6)より高い
      let(:current_value) { 23.7 }
      let(:previous_value) { 23.6 }

      it '前回と同じ設定温度と理由を返す' do
        expect(regulate).to eq({ temperature: previous_set_temperature, reason: :improving_trend })
      end
    end

    context '前回の設定温度が最低設定温度の場合' do
      let(:previous_set_temperature) { described_class::MIN_SET_TEMPERATURE }
      # 現在(24.3)が目標(24) + 許容範囲(0.2)より高く、
      # かつ現在(24.3)が前回(24.2)より高い
      let(:current_value) { 24.3 }
      let(:previous_value) { 24.2 }

      it '最低設定温度と理由が返される（クランプされる）' do
        expect(regulate).to eq({ temperature: described_class::MIN_SET_TEMPERATURE, reason: :at_limit })
      end
    end

    context '前回の設定温度が最高設定温度の場合' do
      let(:previous_set_temperature) { described_class::MAX_SET_TEMPERATURE }
      # 現在(23.7)が目標(24) - 許容範囲(0.2)より低く、
      # かつ現在(23.7)が前回(23.8)より低い
      let(:current_value) { 23.7 }
      let(:previous_value) { 23.8 }

      it '最高設定温度と理由が返される（クランプされる）' do
        expect(regulate).to eq({ temperature: described_class::MAX_SET_TEMPERATURE, reason: :at_limit })
      end
    end
  end
end
