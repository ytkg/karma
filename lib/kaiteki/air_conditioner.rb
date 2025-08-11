# frozen_string_literal: true

require 'hitoku'
require_relative '../mock'
require 'switchbot'

class Kaiteki
  # エアコンの操作（状態確認、温度設定）の責務を持つクラス
  class AirConditioner
    PLUG_DEVICE_ID = 'D83BDA170B26'
    IR_DEVICE_ID = '02-202103110155-72537419'

    # @return [Boolean] エアコンがオフかどうか
    def off?
      # エアコンの電源プラグ（SwitchBotプラグ）の消費電力を確認する
      status = switchbot_client.device(PLUG_DEVICE_ID).status
      # 10W未満ならオフとみなす
      status[:body][:weight] < 10
    end

    # @param temperature [Integer] 設定温度
    def set_temperature(temperature)
      return if development?

      aircon_ir_device.commands(command: 'setAll', parameter: "#{temperature},2,1,on", command_type: 'command')
    end

    private

    def switchbot_client
      @switchbot_client ||= Switchbot::Client.new(Hitoku.switchbot_api_token, Hitoku.switchbot_api_secret)
    end

    def aircon_ir_device
      switchbot_client.device(IR_DEVICE_ID)
    end

    def development?
      ENV.fetch('KARMA_ENV', nil) == 'development'
    end
  end
end
