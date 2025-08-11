require 'spec_helper'
require_relative '../../../lib/kaiteki/metrics_repository'

RSpec.describe Kaiteki::MetricsRepository do
  let(:repository) { described_class.new }
  let(:ambient_client_mock) { instance_double(Ambient) }

  before do
    allow(Ambient).to receive(:new).and_return(ambient_client_mock)
  end

  describe '#initialize' do
    it 'Ambientクライアントを正しく初期化すること' do
      # `lib/mock.rb` でモックされている値を期待する
      expect(Ambient).to receive(:new).with(
        '93486',
        write_key: 'YOUR_AMBIENT_WRITE_KEY',
        read_key: 'YOUR_AMBIENT_READ_KEY'
      )
      repository
    end
  end

  describe '#read_latest' do
    let(:ambient_data) do
      {
        d1: 25.0,
        d2: 50,
        d3: 73.5,
        d4: 26,
        d5: 24.0,
        created: '2023-08-10T12:00:00.000Z'
      }
    end
    let(:expected_metrics) do
      {
        temperature: 25.0,
        humidity: 50,
        discomfort_index: 73.5,
        set_temperature: 26,
        misnar_feeling_temperature: 24.0
      }
    end

    before do
      allow(ambient_client_mock).to receive(:read).and_return([ambient_data])
    end

    it 'Ambientから読み取ったデータを正しいキーを持つハッシュに変換すること' do
      expect(repository.read_latest).to eq(expected_metrics)
    end
  end

  describe '#send' do
    let(:metrics_to_send) do
      {
        temperature: 28.0,
        humidity: 60,
        discomfort_index: 78.0,
        set_temperature: 27,
        misnar_feeling_temperature: 26.5
      }
    end
    let(:expected_payload) do
      {
        d1: 28.0,
        d2: 60,
        d3: 78.0,
        d4: 27,
        d5: 26.5
      }
    end

    it '渡されたメトリクスをAmbientに送信すること' do
      expect(ambient_client_mock).to receive(:send).with(expected_payload)
      repository.send(metrics_to_send)
    end
  end
end
