if ENV['KARMA_ENV'] == 'jules' || ENV['KARMA_ENV'] == 'test'
  module Hitoku
    def self.method_missing(method_name, *arguments, &block)
      if method_name.to_s.end_with?('_api_token', '_api_secret', '_write_key', '_read_key', '_token')
        "YOUR_#{method_name.to_s.upcase}"
      else
        super
      end
    end

    def self.respond_to_missing?(method_name, include_private = false)
      method_name.to_s.end_with?('_api_token', '_api_secret', '_write_key', '_read_key', '_token') || super
    end
  end
end

if ENV['KARMA_ENV'] == 'jules'
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
