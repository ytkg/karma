require_relative '../../app/kaiteki'

describe Kaiteki do
  describe '#execute' do
    subject(:execute) { described_class.new(target_temperature).execute }

    let(:metrics_repository) { instance_double(Kaiteki::MetricsRepository) }
    let(:meter) { instance_double(Kaiteki::Meter) }
    let(:air_conditioner) { instance_double(Kaiteki::AirConditioner) }
    # Use a real TemperatureRegulator instance to test the integration
    let(:temperature_regulator) { TemperatureRegulator.new(target_temperature) }

    before do
      allow(Kaiteki::MetricsRepository).to receive(:new).and_return(metrics_repository)
      allow(Kaiteki::Meter).to receive(:new).and_return(meter)
      allow(Kaiteki::AirConditioner).to receive(:new).and_return(air_conditioner)
      # Stub the TemperatureRegulator new method to control its instance
      allow(TemperatureRegulator).to receive(:new).with(any_args).and_return(temperature_regulator)

      allow(air_conditioner).to receive(:off?).and_return(false)
      allow(air_conditioner).to receive(:set_temperature)
      allow(metrics_repository).to receive(:send)
    end

    context 'when the effective temperature is higher than the target and the trend is unfavorable' do
      let(:target_temperature) { 23 }

      it 'lowers the air conditioner temperature and records the current metrics' do
        allow(meter).to receive(:fetch_metrics).and_return(
          { temperature: 24.3, humidity: 63, discomfort_index: 72.1, misnar_feeling_temperature: 23.4 }
        )
        allow(metrics_repository).to receive(:read_latest).and_return(
          { temperature: 23.8, humidity: 62, discomfort_index: 71, set_temperature: 28, misnar_feeling_temperature: 23.3 }
        )
        # With the values above:
        # current_value (23.4) is higher than target (23) + allowable_range (0.2), so it should try to lower the temp.
        # The trend is unfavorable because the value is moving away from the target:
        # |23.4 - 23| = 0.4 is >= |23.3 - 23| = 0.3
        # So, the temperature should be lowered by 1 degree from the previous set temperature (28 -> 27).

        expect(air_conditioner).to receive(:set_temperature).with(27)

        expected_metrics = { temperature: 24.3, humidity: 63, discomfort_index: 72.1, misnar_feeling_temperature: 23.4, set_temperature: 27 }
        expected_comment = '体感温度が23.4°だったので、エアコンの設定温度を27°に変更しました'
        expect(metrics_repository).to receive(:send).with(expected_metrics, comment: expected_comment)

        execute
      end
    end

    context 'when the effective temperature is within the allowable range' do
      let(:target_temperature) { 23 }

      it 'does not change the air conditioner temperature' do
        allow(meter).to receive(:fetch_metrics).and_return(
          { temperature: 24.0, humidity: 60, discomfort_index: 70.0, misnar_feeling_temperature: 23.1 }
        )
        allow(metrics_repository).to receive(:read_latest).and_return(
          { temperature: 23.8, humidity: 62, discomfort_index: 71, set_temperature: 28, misnar_feeling_temperature: 23.3 }
        )
        # current_value (23.1) is within target (23) +/- allowable_range (0.2).
        # So, the temperature should not be changed.

        expect(air_conditioner).not_to receive(:set_temperature)

        expected_metrics = { temperature: 24.0, humidity: 60, discomfort_index: 70.0, misnar_feeling_temperature: 23.1, set_temperature: 28 }
        expected_comment = '体感温度が23.1°だったため、エアコンの設定温度は変更しませんでした'
        expect(metrics_repository).to receive(:send).with(expected_metrics, comment: expected_comment)

        execute
      end
    end
  end
end
