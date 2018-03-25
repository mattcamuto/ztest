# main indexing class.
# Can submit documents to the store and search for them by keyword
#
require 'ztest/index/index_schema'

module Ztest
  module Index
    class SearchIndex
      class SearchIndexDocumentError < StandardError
      end

      class MissingDocumentError < StandardError
      end

      def initialize(document_store, document_validator, tokenizer, inverted_index)
        @index_schemas = {}
        @document_store = document_store
        @document_validator = document_validator
        @tokenizer = tokenizer
        @inverted_index = inverted_index
      end

      def find_or_create_schema(schema_name)
        @index_schemas[schema_name.to_s.downcase.delete(' ')] ||= ::Ztest::Index::IndexSchema.new(schema_name)
      end

      # TODO::Test
      def index_names
        @index_schemas.keys
      end


      def add_document(index, document)
        validate_index(index)
        @document_validator.validate!(document)
        tokenized = @tokenizer.tokenize(document)
        @document_store.write(document_key(index, document), document)
        @inverted_index.add(index.to_s.downcase.delete(' '), tokenized)
        @index_schemas[index.to_s.downcase.delete(' ')].add_document_keys(tokenized.keys)
      end

      def index_keys(index)
        @index_schemas[index.to_s.downcase.delete(' ')].document_keys
      end

      def find(index, id)
        validate_index(index)

        @document_store.read(document_index_pk(index, id)).tap do |res|
          if res.nil?
            raise MissingDocumentError.new("SearchIndex: Document not found, index=#{index} id=#{id}")
          end
        end
      end

      def search(index, key, *search_terms)
        ids = search_terms.map { |term| @inverted_index.lookup(index, key, term) }.flatten
        @document_store.read_multi(*ids.map { |id| document_index_pk(index, id) }).values
      end

      private

      def validate_index(index)
        unless @index_schemas[index.to_s.downcase.delete(' ')]
          raise SearchIndexDocumentError.new("SearchIndex: The index schema #{index} is not defined")
        end
      end


      def document_index_pk(index, id)
        [index.to_s.downcase.delete(' '), id].join(':')
      end

      def document_key(index, document)
        [index.to_s.downcase.delete(' '), document['_id']].join(':')
      end

    end
  end
end
