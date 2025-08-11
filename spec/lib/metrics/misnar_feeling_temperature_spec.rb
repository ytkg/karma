require_relative '../../../lib/metrics/misnar_feeling_temperature'

describe Metrics::MisnarFeelingTemperature do
  describe '.calculate' do
    subject { described_class.calculate(temperature, humidity) }

    context '気温が25度で湿度が60%の場合' do
      let(:temperature) { 25 }
      let(:humidity) { 60 }

      it { is_expected.to eq(23.8) }
    end

    context '気温が30度で湿度が80%の場合' do
      let(:temperature) { 30 }
      let(:humidity) { 80 }

      it { is_expected.to eq(29.1) }
    end

    context '気温が10度で湿度が40%の場合' do
      let(:temperature) { 10 }
      let(:humidity) { 40 }

      it { is_expected.to eq(12.6) }
    end
  end
end
