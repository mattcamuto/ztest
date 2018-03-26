module Ztest
  module Finders
    class HasManyFinder
      attr_accessor :child_index_name

      def initialize(child_index_name, child_index_key, search_adapter)
        @child_index_name = child_index_name
        @child_index_key = child_index_key
        @search_adapter = search_adapter
      end

      def composite_index_key
        [@child_index_name,@child_index_key].join('-')
      end

      def load_related_objects(target_objects)
        return [] if target_objects.empty?
        ids = target_objects.map { |hsh| hsh['_id'] }.uniq
        @search_adapter.search(@child_index_name, @child_index_key, *ids)
      end

      def filter_loaded_objects(loaded_collection, parent_id)
        Array(loaded_collection).compact.select do |hash|
          hash[@child_index_key.to_s].to_s == parent_id.to_s
        end
      end
    end
  end
end
