module Metrics
  module DiscomfortIndex
    def self.calculate(temperature, humidity)
      (0.81 * temperature + humidity * 0.01 * (0.99 * temperature - 14.3) + 46.3).round(1)
    end
  end
end
