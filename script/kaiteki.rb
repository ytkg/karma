#!/usr/bin/env ruby

require_relative '../lib/kaiteki'
require 'hitoku'
require 'switchbot'
require 'ruby-ambient'

switchbot_client = Switchbot::Client.new(Hitoku.switchbot_api_token, Hitoku.switchbot_api_secret)
ambient_client = Ambient.new('93486', write_key: Hitoku.ambient_write_key, read_key: Hitoku.ambient_read_key)

options = {
  aircon_id: '02-202103110155-72537419',
  meter_id: 'B0E9FE5580EE',
  plug_id: 'D83BDA170B26'
}

Kaiteki.new(
  switchbot_client: switchbot_client,
  ambient_client: ambient_client,
  options: options
).execute
