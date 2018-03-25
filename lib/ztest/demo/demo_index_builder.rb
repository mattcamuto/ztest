require 'oj'
require 'ztest/finders/has_many_finder'


module Ztest
  module Demo
    class DemoIndexBuilder

      # Factory method to load the files and build the indexes for this
      # test. In a rails app this would be done via an actual configuration
      # block in an initializer. This class is mostly pathological for this test.

      def self.load_and_create_index
        document_store = Ztest::DocumentStores::LocalDocumentStore.new
        validator = Ztest::DocumentValidator.new
        tokenizer = Ztest::DocumentTokenizer.new
        invert_index = Ztest::Index::InvertIndex.new
        Ztest::Index::SearchIndex.new(document_store,
                                      validator,
                                      tokenizer,
                                      invert_index).tap do |index|
          load_up_index(index, :users, load_json('users'))
          load_up_index(index, :organizations, load_json('organizations'))
          load_up_index(index, :tickets, load_json('tickets'))

          load_has_many(index)
        end
      end

      def self.load_json(fil_name)
        js_path = File.expand_path("../../../../data/#{fil_name}.json", __FILE__)
        contents = File.read(js_path)
        Oj.compat_load(contents)
      end

      private_class_method :load_json

      def self.load_up_index(search_index, index_name, data)
        search_index.find_or_create_schema(index_name)
        data.each { |object| search_index.add_document(index_name, object) }
      end

      private_class_method :load_up_index


      def self.load_has_many(search_index)
        user_schema = search_index.find_or_create_schema(:users)

        finder = ::Ztest::Finders::HasManyFinder.new('tickets','submitter_id',search_index)
        user_schema.has_many_finders << finder

        finder = ::Ztest::Finders::HasManyFinder.new('tickets','assignee_id',search_index)
        user_schema.has_many_finders << finder

        tickets_schema = search_index.find_or_create_schema(:tickets)
        tickets_schema.title_field = 'subject'

        organizations_schema = search_index.find_or_create_schema(:organizations)
        finder = ::Ztest::Finders::HasManyFinder.new('users','organization_id',search_index)
        organizations_schema.has_many_finders << finder
      end

      private_class_method :load_has_many

    end
  end
end
