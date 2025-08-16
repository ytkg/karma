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

      it '1度下げた温度を返す' do
        expect(regulate).to eq(24)
      end
    end

    context '値を上げるべき場合' do
      # 現在(23.7)が目標(24) - 許容範囲(0.2)より低く、
      # かつ現在(23.7)が前回(23.8)より低い
      let(:current_value) { 23.7 }
      let(:previous_value) { 23.8 }

      it '1度上げた温度を返す' do
        expect(regulate).to eq(26)
      end
    end

    context '値を変更すべきでない場合' do
      # 現在(24.1)が目標(24) +/- 許容範囲(0.2)の範囲内
      let(:current_value) { 24.1 }
      let(:previous_value) { 24.0 }

      it '前回と同じ設定温度を返す' do
        expect(regulate).to eq(previous_set_temperature)
      end
    end

    context '値が上昇しているが、まだ許容範囲内の場合' do
      # 現在(24.1)が目標(24) +/- 許容範囲(0.2)の範囲内で、
      # かつ現在(24.1)が前回(24.0)より高い
      let(:current_value) { 24.1 }
      let(:previous_value) { 24.0 }

      it '前回と同じ設定温度を返す' do
        expect(regulate).to eq(previous_set_temperature)
      end
    end

    context '値が下降しているが、まだ許容範囲内の場合' do
      # 現在(23.9)が目標(24) +/- 許容範囲(0.2)の範囲内で、
      # かつ現在(23.9)が前回(24.0)より低い
      let(:current_value) { 23.9 }
      let(:previous_value) { 24.0 }

      it '前回と同じ設定温度を返す' do
        expect(regulate).to eq(previous_set_temperature)
      end
    end

    context '目標より値が高いが、下降傾向にある場合' do
      # 現在(24.3)が目標(24) + 許容範囲(0.2)より高いが、
      # 現在(24.3)が前回(24.4)より低い
      let(:current_value) { 24.3 }
      let(:previous_value) { 24.4 }

      it '前回と同じ設定温度を返す' do
        expect(regulate).to eq(previous_set_temperature)
      end
    end

    context '目標より値が低いが、上昇傾向にある場合' do
      # 現在(23.7)が目標(24) - 許容範囲(0.2)より低いが、
      # 現在(23.7)が前回(23.6)より高い
      let(:current_value) { 23.7 }
      let(:previous_value) { 23.6 }

      it '前回と同じ設定温度を返す' do
        expect(regulate).to eq(previous_set_temperature)
      end
    end

    context '前回の設定温度が最低設定温度の場合' do
      let(:previous_set_temperature) { described_class::MIN_SET_TEMPERATURE }
      # 現在(24.3)が目標(24) + 許容範囲(0.2)より高く、
      # かつ現在(24.3)が前回(24.2)より高い
      let(:current_value) { 24.3 }
      let(:previous_value) { 24.2 }

      it '最低設定温度が返される（クランプされる）' do
        expect(regulate).to eq(described_class::MIN_SET_TEMPERATURE)
      end
    end

    context '前回の設定温度が最高設定温度の場合' do
      let(:previous_set_temperature) { described_class::MAX_SET_TEMPERATURE }
      # 現在(23.7)が目標(24) - 許容範囲(0.2)より低く、
      # かつ現在(23.7)が前回(23.8)より低い
      let(:current_value) { 23.7 }
      let(:previous_value) { 23.8 }

      it '最高設定温度が返される（クランプされる）' do
        expect(regulate).to eq(described_class::MAX_SET_TEMPERATURE)
      end
    end
  end
end
