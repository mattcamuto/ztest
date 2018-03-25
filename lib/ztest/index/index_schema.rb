module Ztest
  module Index
    class IndexSchema
      attr_accessor :name
      attr_accessor :title_field
      attr_accessor :has_many_finders

      def initialize(name)
        self.name = name
        self.has_many_finders = []
        @keys = Set.new
      end

      def add_document_keys(keys)
        keys.each { |k| @keys.add(k) }
      end

      def document_keys
        @keys.to_a
      end

    end
  end
end
