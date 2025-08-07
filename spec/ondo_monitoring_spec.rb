require 'spec_helper'

# Define a dummy Hitoku module before loading the script
module Hitoku
  def self.switchbot_api_token
    'test_token'
  end

  def self.switchbot_api_secret
    'test_secret'
  end

  def self.ambient_monitoring_write_key
    'test_write_key'
  end
end

require_relative '../script/ondo_monitoring'

RSpec.describe OndoMonitoring do
  describe 'private methods' do
    describe '.calculate_discomfort_index' do
      it 'calculates the discomfort index correctly' do
        # Example: Temperature 25°C, Humidity 60%
        expect(described_class.send(:calculate_discomfort_index, 25, 60)).to be_within(0.1).of(72.8)
      end
    end

    describe '.misnar_feeling_temperature' do
      it 'calculates the Misnar feeling temperature correctly' do
        # Example: Temperature 25°C, Humidity 60%
        expect(described_class.send(:misnar_feeling_temperature, 25, 60)).to be_within(0.1).of(23.8)
      end
    end
  end

  describe '.fetch_metrics' do
    let(:device_id) { 'TEST_DEVICE_ID' }
    let(:switchbot_client) { instance_double(Switchbot::Client) }
    let(:device_status_response) { double('device_status_response', body: { temperature: 22.5, humidity: 55 }) }
    let(:device) { instance_double(Switchbot::Device, status: device_status_response) }

    before do
      # Stub Switchbot::Client chain
      allow(Switchbot::Client).to receive(:new).with('test_token', 'test_secret').and_return(switchbot_client)
      allow(switchbot_client).to receive(:device).with(device_id).and_return(device)
    end

    it 'fetches metrics and calculates derived values' do
      metrics = described_class.fetch_metrics(device_id)

      expect(metrics[:temperature]).to eq(22.5)
      expect(metrics[:humidity]).to eq(55)
      expect(metrics[:discomfort_index]).to be_within(0.1).of(68.9)
      expect(metrics[:misnar_feeling_temperature]).to be_within(0.1).of(21.7)
    end
  end

  describe '.run' do
    let(:ambient_client) { instance_double(Ambient) }
    let(:metrics1) do
      { temperature: 25.0, humidity: 60, discomfort_index: 72.8, misnar_feeling_temperature: 23.8 }
    end
    let(:metrics2) do
      { temperature: 20.0, humidity: 50, discomfort_index: 65.1, misnar_feeling_temperature: 18.3 }
    end

    before do
      # Stub fetch_metrics
      allow(described_class).to receive(:fetch_metrics).with('B0E9FE5580EE').and_return(metrics1)
      allow(described_class).to receive(:fetch_metrics).with('E3F7060488E0').and_return(metrics2)

      # Stub Ambient client
      allow(Ambient).to receive(:new).with('93505', write_key: 'test_write_key').and_return(ambient_client)
      allow(ambient_client).to receive(:send)
    end

    it 'fetches metrics for both devices and sends them to Ambient' do
      described_class.run

      expect(ambient_client).to have_received(:send).with(
        d1: 25.0, d2: 60, d3: 72.8, d4: 23.8,
        d5: 20.0, d6: 50, d7: 65.1, d8: 18.3
      )
    end
  end
end
