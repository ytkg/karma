require_relative '../../../lib/metrics/discomfort_index'

describe Metrics::DiscomfortIndex do
  describe '.calculate' do
    subject { described_class.calculate(temperature, humidity) }

    context 'when temperature is 25 and humidity is 60' do
      let(:temperature) { 25 }
      let(:humidity) { 60 }

      it { is_expected.to eq(72.82) }
    end

    context 'when temperature is 30 and humidity is 80' do
      let(:temperature) { 30 }
      let(:humidity) { 80 }

      it { is_expected.to eq(82.92) }
    end

    context 'when temperature is 10 and humidity is 40' do
      let(:temperature) { 10 }
      let(:humidity) { 40 }

      it { is_expected.to eq(52.64) }
    end
  end
end
