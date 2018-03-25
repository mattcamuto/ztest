module Ztest
  module Helper
    module SafeStr
      def safe_str(obj)
        obj.to_s.delete(' ').downcase
      end
    end
  end
end
