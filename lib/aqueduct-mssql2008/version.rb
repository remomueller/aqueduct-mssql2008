module Aqueduct
  module Mssql2008
    module VERSION
      MAJOR = 0
      MINOR = 1
      TINY = 0
      BUILD = nil # nil, "pre", "rc", "rc2"

      STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.')
    end
  end
end
