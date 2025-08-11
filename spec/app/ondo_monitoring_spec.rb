require_relative '../../app/ondo_monitoring'

describe OndoMonitoring do
  describe '#execute' do
    subject(:execute) { described_class.new.execute }

    let(:switchbot_client_mock) { instance_double('Switchbot::Client') }
    let(:switchbot_device_mock1) { instance_double('Switchbot::Device') }
    let(:switchbot_device_mock2) { instance_double('Switchbot::Device') }
    let(:ambient_client_mock) { instance_double('Ambient') }

    before do
      allow(Switchbot::Client).to receive(:new).and_return(switchbot_client_mock)
      allow(switchbot_client_mock).to receive(:device).with('B0E9FE5580EE').and_return(switchbot_device_mock1)
      allow(switchbot_client_mock).to receive(:device).with('E3F7060488E0').and_return(switchbot_device_mock2)

      allow(switchbot_device_mock1).to receive(:status).and_return(
        {
          body: {
            temperature: 25.0,
            humidity: 50
          }
        }
      )
      allow(switchbot_device_mock2).to receive(:status).and_return(
        {
          body: {
            temperature: 26.0,
            humidity: 60
          }
        }
      )

      allow(Ambient).to receive(:new).and_return(ambient_client_mock)
      allow(ambient_client_mock).to receive(:send)
    end

    it 'sends correct metrics to Ambient' do
      # Mocking the calculation methods to isolate the test to the execute method's logic
      # misnar_feeling_temperature is complex, so we'll just check if it's called
      # and what the final payload to ambient is.

      # Expected values based on the mock data
      # Device 1: temp=25.0, hum=50
      # DI = (0.81 * 25 + 50 * 0.01 * (0.99 * 25 - 14.3) + 46.3).round(1)
      # DI = (20.25 + 0.5 * (24.75 - 14.3) + 46.3).round(1)
      # DI = (20.25 + 0.5 * 10.45 + 46.3).round(1)
      # DI = (20.25 + 5.225 + 46.3).round(1)
      # DI = (71.775).round(1) = 71.8
      # MFT = (37 - ((37 - 25) / (1.24828 - 0.0014 * 50)) - 0.29 * 25 * (1 - 50 / 100.0)).round(1)
      # MFT = (37 - (12 / (1.24828 - 0.07)) - 7.25 * 0.5).round(1)
      # MFT = (37 - (12 / 1.17828) - 3.625).round(1)
      # MFT = (37 - 10.1843... - 3.625).round(1)
      # MFT = (23.190...).round(1) = 23.2

      # Device 2: temp=26.0, hum=60
      # DI = (0.81 * 26 + 60 * 0.01 * (0.99 * 26 - 14.3) + 46.3).round(1)
      # DI = (21.06 + 0.6 * (25.74 - 14.3) + 46.3).round(1)
      # DI = (21.06 + 0.6 * 11.44 + 46.3).round(1)
      # DI = (21.06 + 6.864 + 46.3).round(1)
      # DI = (74.224).round(1) = 74.2
      # MFT = (37 - ((37 - 26) / (1.24828 - 0.0014 * 60)) - 0.29 * 26 * (1 - 60 / 100.0)).round(1)
      # MFT = (37 - (11 / (1.24828 - 0.084)) - 7.54 * 0.4).round(1)
      # MFT = (37 - (11 / 1.16428) - 3.016).round(1)
      # MFT = (37 - 9.4478... - 3.016).round(1)
      # MFT = (24.536...).round(1) = 24.5

      expect(ambient_client_mock).to receive(:send).with(
        d1: 25.0, d2: 50, d3: 71.8, d4: 23.2,
        d5: 26.0, d6: 60, d7: 74.2, d8: 24.5
      )

      execute
    end
  end
end
