# frozen_string_literal: true

require 'hitoku'
require_relative '../mock'
require 'ruby-ambient'

class Kaiteki
  class MetricsRepository
    CHANNEL_ID = '93486'

    def initialize
      @client = Ambient.new(
        CHANNEL_ID,
        write_key: Hitoku.ambient_write_key,
        read_key: Hitoku.ambient_read_key
      )
    end

    # 最新のメトリクスを永続化先から取得する
    # @return [Hash] 最新のメトリクス
    def read_latest
      metrics = @client.read.last

      {
        temperature: metrics[:d1],
        humidity: metrics[:d2],
        discomfort_index: metrics[:d3],
        set_temperature: metrics[:d4],
        misnar_feeling_temperature: metrics[:d5]
      }
    end

    # メトリクスをAmbientに送信する
    # @param metrics [Hash] 送信するメトリクス
    # @param comment [String] コメント
    def send(metrics, comment:)
      return if development?

      payload = {
        d1: metrics[:temperature],
        d2: metrics[:humidity],
        d3: metrics[:discomfort_index],
        d4: metrics[:set_temperature],
        d5: metrics[:misnar_feeling_temperature],
        cmnt: comment
      }

      @client.send(payload)
    end

    private

    def development?
      ENV.fetch('KARMA_ENV', nil) == 'development'
    end
  end
end
