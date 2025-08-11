require 'spec_helper'
require_relative '../../../lib/kaiteki/meter'

RSpec.describe Kaiteki::Meter do
  describe '#fetch_metrics' do
    subject(:fetch_metrics) { described_class.new.fetch_metrics }

    let(:switchbot_client_mock) { instance_double(Switchbot::Client) }
    let(:device_mock) { instance_double('device') }
    let(:status_mock) do
      {
        body: {
          temperature: 25.0,
          humidity: 50.0
        }
      }
    end

    before do
      allow(Switchbot::Client).to receive(:new).and_return(switchbot_client_mock)
      allow(switchbot_client_mock).to receive(:device).with('B0E9FE5580EE').and_return(device_mock)
      allow(device_mock).to receive(:status).and_return(status_mock)

      # NOTE: `Metrics` is a top-level module
      allow(::Metrics::DiscomfortIndex).to receive(:calculate).and_return(73.5)
      allow(::Metrics::MisnarFeelingTemperature).to receive(:calculate).and_return(24.0)
    end

    it 'SwitchBot APIから取得した値と計算結果をハッシュで返すこと' do
      expect(fetch_metrics).to eq(
        temperature: 25.0,
        humidity: 50.0,
        discomfort_index: 73.5,
        misnar_feeling_temperature: 24.0
      )
    end

    it 'DiscomfortIndex.calculateに正しい引数を渡すこと' do
      fetch_metrics
      expect(::Metrics::DiscomfortIndex).to have_received(:calculate).with(25.0, 50.0)
    end

    it 'MisnarFeelingTemperature.calculateに正しい引数を渡すこと' do
      fetch_metrics
      expect(::Metrics::MisnarFeelingTemperature).to have_received(:calculate).with(25.0, 50.0)
    end
  end
end
