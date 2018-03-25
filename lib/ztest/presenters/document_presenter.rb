module Ztest
  module Presenters
    class DocumentPresenter

      def initialize(schema_definition, document)
        @schema_definition = schema_definition
        @document = document
        @children = {}
      end

      def index_name
        @schema_definition.name.to_s
      end

      def pretty_title
        title_field = @schema_definition.title_field || 'name'
        "#{@document[title_field]} (#{@document['_id']})"
      end

      def add_child_doc(key, doc)
        @children[key] ||= []
        @children[key] << doc
      end

      def table_data
        #binding.pry

        Hash[@document.sort].to_a.tap do |hash|
          @children.each_pair do |k,v|
            v.each_with_index do |item,idx|
              disp_key = [k,idx].join('.')
              hash << [disp_key,item.pretty_title]
            end
          end
        end
      end
    end
  end
end
