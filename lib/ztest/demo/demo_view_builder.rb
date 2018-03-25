require 'ztest/presenters/document_presenter'

module Ztest
  module Demo
    class DemoViewBuilder

      def initialize(search_index)
        @search_index = search_index
      end

      def search_and_present(index, key, *search_terms)
        entities = @search_index.search(index, key, *search_terms)
        schema = @search_index.find_or_create_schema(index)
        eager_hash = create_eager_load_hash(schema,entities)
        entities.map do |e|
          ::Ztest::Presenters::DocumentPresenter.new(schema, e).tap do |doc|
            schema.has_many_finders.each do |f|
              child_schema = @search_index.find_or_create_schema(f.child_index_name)
              f.filter_loaded_objects(eager_hash[f.composite_index_key], e['_id']).each do |child_doc|
                child = ::Ztest::Presenters::DocumentPresenter.new(child_schema, child_doc)
                doc.add_child_doc(f.composite_index_key,child)
              end
            end
          end
        end
      end

      private

      def create_eager_load_hash(schema,entities)
        {}.tap do |eager_hash|
          schema.has_many_finders.each do |f|
            eager_hash[f.composite_index_key] = f.load_related_objects(entities)
          end
        end
      end
    end
  end
end
