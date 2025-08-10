if ENV['KARMA_ENV'] == 'test'
  module Hitoku
    def self.switchbot_api_token
      'YOUR_SWITCHBOT_API_TOKEN'
    end

    def self.switchbot_api_secret
      'YOUR_SWITCHBOT_API_SECRET'
    end

    def self.ambient_write_key
      'YOUR_AMBIENT_WRITE_KEY'
    end

    def self.ambient_read_key
      'YOUR_AMBIENT_READ_KEY'
    end
  end

  require 'webmock'

  include WebMock::API
  WebMock.enable!

  stub_request(:get, /https:\/\/api.switch-bot.com\/v1.1\/devices/)
    .to_return(
      body: {
        body: {
          temperature: 24,
          humidity: 65,
          weight: 300
        }
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
  )

  stub_request(:get, /http:\/\/ambidata.io\/api\/v2\/channels/)
    .to_return(
      body: [{
        d1: 24.3,
        d2: 67,
        d3: 72.23,
        d4: 28
      }].to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

  stub_request(:post, /http:\/\/ambidata.io\/api\/v2\/channels/)
end
