module Metrics
  module MisnarFeelingTemperature
    def self.calculate(temperature, humidity)
      (37 - ((37 - temperature) / (1.24828 - 0.0014 * humidity)) - 0.29 * temperature * (1 - humidity / 100.0)).round(1)
    end
  end
end
