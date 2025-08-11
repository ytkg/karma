require_relative '../../app/kaiteki'

describe Kaiteki do
  describe '#execute' do
    subject(:execute) { described_class.new.execute }

    let(:switchbot_client_mock) { instance_double('mock') }
    let(:switchbot_device_mock) { instance_double('mock') }
    let(:switchbot_device_status_mock) { instance_double('mock') }
    let(:ambient_client_mock) { instance_double('mock') }

    before do
      allow(Switchbot::Client).to receive(:new).and_return(switchbot_client_mock)
      allow(switchbot_client_mock).to receive(:device).and_return(switchbot_device_mock)
      allow(switchbot_device_mock).to receive(:status).and_return(
        {
          body: {
            temperature: 24.3,
            humidity: 63,
            weight: 300
          }
        }
      )
      allow(switchbot_device_mock).to receive(:commands)
      allow(Ambient).to receive(:new).and_return(ambient_client_mock)
      allow(ambient_client_mock).to receive(:read).and_return(
        [
          d1: 23.8,
          d2: 62,
          d3: 71,
          d4: 28,
          d5: 23.0
        ]
      )
      allow(ambient_client_mock).to receive(:send)
    end


    it do
      expect(ambient_client_mock).to receive(:send).with(
        d1: 24.3,
        d2: 63,
        d3: 72.1,
        d4: 27,
        d5: 23.4
      )

      execute
    end
  end
end

