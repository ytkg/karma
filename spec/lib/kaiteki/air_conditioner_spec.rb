require 'spec_helper'
require_relative '../../../lib/kaiteki/air_conditioner'

RSpec.describe Kaiteki::AirConditioner do
  let(:air_conditioner) { described_class.new }
  let(:switchbot_client_mock) { instance_double(Switchbot::Client) }
  let(:plug_device_mock) { instance_double('plug_device') }
  let(:ir_device_mock) { instance_double('ir_device') }

  before do
    allow(Switchbot::Client).to receive(:new).and_return(switchbot_client_mock)
    allow(switchbot_client_mock).to receive(:device).with('D83BDA170B26').and_return(plug_device_mock)
    allow(switchbot_client_mock).to receive(:device).with('02-202103110155-72537419').and_return(ir_device_mock)
  end

  describe '#off?' do
    subject(:off?) { air_conditioner.off? }

    context '消費電力が10W未満の場合' do
      before do
        allow(plug_device_mock).to receive(:status).and_return({ body: { weight: 9.9 } })
      end

      it { is_expected.to be true }
    end

    context '消費電力が10W以上の場合' do
      before do
        allow(plug_device_mock).to receive(:status).and_return({ body: { weight: 10.0 } })
      end

      it { is_expected.to be false }
    end
  end

  describe '#set_temperature' do
    subject(:set_temperature) { air_conditioner.set_temperature(25) }

    before do
      allow(ir_device_mock).to receive(:commands)
    end

    context '通常環境の場合' do
      before do
        allow(air_conditioner).to receive(:development?).and_return(false)
      end

      it 'SwitchBot APIを呼び出すこと' do
        set_temperature
        expect(ir_device_mock).to have_received(:commands).with(
          command: 'setAll',
          parameter: '25,2,1,on',
          command_type: 'command'
        )
      end
    end

    context '開発環境の場合' do
      before do
        allow(air_conditioner).to receive(:development?).and_return(true)
      end

      it 'SwitchBot APIを呼び出さないこと' do
        set_temperature
        expect(ir_device_mock).not_to have_received(:commands)
      end
    end
  end
end
