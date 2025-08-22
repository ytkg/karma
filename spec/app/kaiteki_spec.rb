require_relative '../../app/kaiteki'

describe Kaiteki do
  describe '#execute' do
    subject(:execute) { described_class.new(target_temperature).execute }

    let(:metrics_repository) { instance_double(Kaiteki::MetricsRepository) }
    let(:meter) { instance_double(Kaiteki::Meter) }
    let(:air_conditioner) { instance_double(Kaiteki::AirConditioner) }
    let(:temperature_regulator) { instance_double(TemperatureRegulator) }

    before do
      allow(Kaiteki::MetricsRepository).to receive(:new).and_return(metrics_repository)
      allow(Kaiteki::Meter).to receive(:new).and_return(meter)
      allow(Kaiteki::AirConditioner).to receive(:new).and_return(air_conditioner)
      allow(TemperatureRegulator).to receive(:new).with(any_args).and_return(temperature_regulator)

      allow(air_conditioner).to receive(:off?).and_return(false)
      allow(air_conditioner).to receive(:set_temperature)
      allow(metrics_repository).to receive(:send)
    end

    context 'エアコンがOFFの場合' do
      let(:target_temperature) { 23 }

      it 'エアコンを操作せずに、理由をコメントしてメトリクスを送信すること' do
        allow(air_conditioner).to receive(:off?).and_return(true)
        allow(meter).to receive(:fetch_metrics).and_return(
          { temperature: 25, humidity: 50, discomfort_index: 73.5, misnar_feeling_temperature: 24.0 }
        )

        expect(air_conditioner).not_to receive(:set_temperature)

        expected_metrics = {
          temperature: 25, humidity: 50, discomfort_index: 73.5, misnar_feeling_temperature: 24.0,
          set_temperature: 0,
          comment: 'エアコンがOFFのため、操作をスキップしました'
        }
        expect(metrics_repository).to receive(:send).with(expected_metrics)

        execute
      end
    end

    context '温度を下げるべきだと判断された場合' do
      let(:target_temperature) { 23 }

      it 'エアコンの設定温度を下げ、理由をコメントしてメトリクスを送信すること' do
        allow(meter).to receive(:fetch_metrics).and_return(
          { temperature: 24.3, humidity: 63, discomfort_index: 72.1, misnar_feeling_temperature: 23.4 }
        )
        allow(metrics_repository).to receive(:read_latest).and_return({ set_temperature: 28 })
        allow(temperature_regulator).to receive(:regulate).and_return({ temperature: 27, reason: :lowered })

        expect(air_conditioner).to receive(:set_temperature).with(27)

        expected_metrics = {
          temperature: 24.3, humidity: 63, discomfort_index: 72.1, misnar_feeling_temperature: 23.4,
          set_temperature: 27,
          comment: '体感温度が23.4°だったので、エアコンの設定温度を27°に変更しました'
        }
        expect(metrics_repository).to receive(:send).with(expected_metrics)

        execute
      end
    end

    context '目標範囲内だと判断された場合' do
      let(:target_temperature) { 23 }

      it 'エアコンを操作せず、理由をコメントしてメトリクスを送信すること' do
        allow(meter).to receive(:fetch_metrics).and_return(
          { temperature: 24.0, humidity: 60, discomfort_index: 70.0, misnar_feeling_temperature: 23.1 }
        )
        allow(metrics_repository).to receive(:read_latest).and_return({ set_temperature: 28 })
        allow(temperature_regulator).to receive(:regulate).and_return({ temperature: 28, reason: :in_range })

        expect(air_conditioner).not_to receive(:set_temperature)

        expected_metrics = {
          temperature: 24.0, humidity: 60, discomfort_index: 70.0, misnar_feeling_temperature: 23.1,
          set_temperature: 28,
          comment: '体感温度が23.1°で目標範囲内のため、エアコンの設定温度は変更しませんでした'
        }
        expect(metrics_repository).to receive(:send).with(expected_metrics)

        execute
      end
    end

    context '改善傾向だと判断された場合' do
      let(:target_temperature) { 23 }

      it 'エアコンを操作せず、理由をコメントしてメトリクスを送信すること' do
        allow(meter).to receive(:fetch_metrics).and_return(
          { temperature: 25.0, humidity: 65, discomfort_index: 75.0, misnar_feeling_temperature: 24.2 }
        )
        allow(metrics_repository).to receive(:read_latest).and_return({ set_temperature: 28 })
        allow(temperature_regulator).to receive(:regulate).and_return({ temperature: 28, reason: :improving_trend })

        expect(air_conditioner).not_to receive(:set_temperature)

        expected_metrics = {
          temperature: 25.0, humidity: 65, discomfort_index: 75.0, misnar_feeling_temperature: 24.2,
          set_temperature: 28,
          comment: '体感温度が24.2°で改善傾向のため、エアコンの設定温度は変更しませんでした'
        }
        expect(metrics_repository).to receive(:send).with(expected_metrics)

        execute
      end
    end
  end
end
