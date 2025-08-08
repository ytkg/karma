require 'spec_helper'
require_relative '../script/kaiteki'

RSpec.describe Kaiteki do
  let(:switchbot_client) { instance_double(Switchbot::Client) }
  let(:ambient_client) { instance_double(Ambient) }
  let(:meter) { instance_double(Switchbot::Device) }
  let(:plug) { instance_double(Switchbot::Device) }
  let(:aircon) { instance_double(Switchbot::Device) }
  let(:kaiteki) { Kaiteki.new(switchbot_client: switchbot_client, ambient_client: ambient_client) }

  before do
    # Stub the device lookups
    allow(switchbot_client).to receive(:device).with('B0E9FE5580EE').and_return(meter)
    allow(switchbot_client).to receive(:device).with('D83BDA170B26').and_return(plug)
    allow(switchbot_client).to receive(:device).with('02-202103110155-72537419').and_return(aircon)

    # Default stubs for device methods
    allow(meter).to receive(:status).and_return({ body: { temperature: 25, humidity: 50 } })
    allow(ambient_client).to receive(:read).and_return([{ d1: 25, d2: 50, d3: 70, d4: 25 }])
    allow(ambient_client).to receive(:send)
    allow(aircon).to receive(:commands)

    # Suppress console output from the script
    allow($stdout).to receive(:puts)
  end

  describe '#execute' do
    context 'when aircon is off' do
      it 'sends metrics with set_temperature 0 and does not control aircon' do
        allow(plug).to receive(:status).and_return({ body: { weight: 5 } })

        expect(ambient_client).to receive(:send).with(hash_including(d4: 0))
        expect(aircon).not_to receive(:commands)

        kaiteki.execute
      end
    end

    context 'when aircon is on' do
      before do
        allow(plug).to receive(:status).and_return({ body: { weight: 20 } })
      end

      context 'when temperature is too high and increasing' do
        it 'lowers the temperature and sends metrics' do
          allow(meter).to receive(:status).and_return({ body: { temperature: 25, humidity: 50 } })
          allow(ambient_client).to receive(:read).and_return([{ d1: 24.8, d2: 50, d3: 70, d4: 26 }])

          expect(aircon).to receive(:commands).with(command: 'setAll', parameter: "25,2,1,on", command_type: 'command')
          expect(ambient_client).to receive(:send).with(hash_including(d4: 25))

          kaiteki.execute
        end
      end

      context 'when temperature is too high but decreasing' do
        it 'does not change the temperature and sends metrics' do
          allow(meter).to receive(:status).and_return({ body: { temperature: 25, humidity: 50 } })
          allow(ambient_client).to receive(:read).and_return([{ d1: 25.2, d2: 50, d3: 70, d4: 26 }])

          expect(aircon).not_to receive(:commands)
          expect(ambient_client).to receive(:send).with(hash_including(d4: 26))

          kaiteki.execute
        end
      end

      context 'when temperature is too low and decreasing' do
        it 'raises the temperature and sends metrics' do
          allow(meter).to receive(:status).and_return({ body: { temperature: 23, humidity: 50 } })
          allow(ambient_client).to receive(:read).and_return([{ d1: 23.2, d2: 50, d3: 70, d4: 22 }])

          expect(aircon).to receive(:commands).with(command: 'setAll', parameter: "23,2,1,on", command_type: 'command')
          expect(ambient_client).to receive(:send).with(hash_including(d4: 23))

          kaiteki.execute
        end
      end

      context 'when temperature is too low but increasing' do
        it 'does not change the temperature and sends metrics' do
          allow(meter).to receive(:status).and_return({ body: { temperature: 23, humidity: 50 } })
          allow(ambient_client).to receive(:read).and_return([{ d1: 22.8, d2: 50, d3: 70, d4: 22 }])

          expect(aircon).not_to receive(:commands)
          expect(ambient_client).to receive(:send).with(hash_including(d4: 22))

          kaiteki.execute
        end
      end

      context 'when temperature is stable' do
        it 'does not change the temperature and sends metrics' do
          allow(meter).to receive(:status).and_return({ body: { temperature: 24.1, humidity: 50 } })
          allow(ambient_client).to receive(:read).and_return([{ d1: 24.1, d2: 50, d3: 70, d4: 24 }])

          expect(aircon).not_to receive(:commands)
          expect(ambient_client).to receive(:send).with(hash_including(d4: 24))

          kaiteki.execute
        end
      end

      context 'when previous set temperature is 0' do
        it 'uses the base temperature to calculate the new set temperature' do
          allow(meter).to receive(:status).and_return({ body: { temperature: 29, humidity: 50 } })
          allow(ambient_client).to receive(:read).and_return([{ d1: 28.8, d2: 50, d3: 70, d4: 0 }])

          expect(aircon).to receive(:commands).with(command: 'setAll', parameter: "27,2,1,on", command_type: 'command')
          expect(ambient_client).to receive(:send).with(hash_including(d4: 27))

          kaiteki.execute
        end
      end
    end
  end
end
