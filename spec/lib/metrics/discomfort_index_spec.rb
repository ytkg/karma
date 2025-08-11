require_relative '../../../lib/metrics/discomfort_index'

describe Metrics::DiscomfortIndex do
  describe '.calculate' do
    subject { described_class.calculate(temperature, humidity) }

    context '気温が25度で湿度が60%の場合' do
      let(:temperature) { 25 }
      let(:humidity) { 60 }

      it { is_expected.to eq(72.82) }
    end

    context '気温が30度で湿度が80%の場合' do
      let(:temperature) { 30 }
      let(:humidity) { 80 }

      it { is_expected.to eq(82.92) }
    end

    context '気温が10度で湿度が40%の場合' do
      let(:temperature) { 10 }
      let(:humidity) { 40 }

      it { is_expected.to eq(52.64) }
    end
  end
end
