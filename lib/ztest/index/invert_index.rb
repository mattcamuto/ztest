# simple inverted index. keyword/token mapped to entity/field
# one level of depth only. for this excercize
# does not index across document types, nor across all fields in a document ??
module Ztest
  module Index
    class InvertIndex
      include ::Ztest::Helper::SafeStr
     
      class IndexError < StandardError
      end

      def initialize
        @inverted_index = {}
      end

      # all entities are keyed as string for this excercise
      def add(entity_type, tokenized_document)
        doc_id = extract_id(tokenized_document) || raise(Ztest::Index::InvertIndex::IndexError.new('InvertIndex: _id field missing.'))
        safe_entity_type = safe_str(entity_type)
        @inverted_index[safe_entity_type] ||= {}
        tokenized_document.each_pair { |k, v| populate_invert(doc_id, safe_entity_type, k, v) }
      end

      # array of keys, returns simple the raw document id
      def lookup(entity_type, key, field)
        idx = @inverted_index[safe_str(entity_type)]
        raise(Ztest::Index::InvertIndex::IndexError.new("InvertIndex: index '#{entity_type}' does not exist!")) unless idx

        idx_key = @inverted_index[safe_str(entity_type)][safe_str(key)]
        raise(Ztest::Index::InvertIndex::IndexError.new("InvertIndex: key '#{key}' for index '#{entity_type}' does not exist!")) unless idx_key

        idx_key[safe_str(field)].to_a
      end

      private

      def populate_invert(doc_id, safe_entity_type, k, v)
        @inverted_index[safe_entity_type][safe_str(k)] ||= {}
        Array(v).each do |val|
          @inverted_index[safe_entity_type][safe_str(k)][safe_str(val)] ||= Set.new
          @inverted_index[safe_entity_type][safe_str(k)][safe_str(val)].add(doc_id)
        end
      end

      def extract_id(tokenized_document)
        Array(tokenized_document['_id']).first
      end
    end
  end
end
