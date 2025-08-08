$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require_relative '../app/kaiteki'

Kaiteki.new.execute
