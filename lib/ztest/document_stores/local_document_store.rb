# Simple backend to store basic documents. All it does is allow single reads
# by key or a group of key. We would be able to swap this out in the real world
# with a different back end. A distributed on if desired, a shared one. Etc
module Ztest
  module DocumentStores

    class KeyException < StandardError
    end

    class LocalDocumentStore
      class DocumentError < StandardError
      end

      def initialize
        @document_store = {}
      end

      def write(key, value)
        unless value.respond_to?(:to_hash)
          raise DocumentError.new('LocalDocumentStore: value must respond_to?(:hash)')
        end
        @document_store[key]=value.to_hash
      end

      # delete element, silent if a miss
      def delete(key)
        @document_store.delete(key)
      end

      def read(key)
        raise KeyException.new('LocalDocumentStore does not support a nil key') if key.nil?
        @document_store[key]
      end

      # Similar to the idea of active support cache. A read multi could span a cluster of
      # services with a complex back end
      def read_multi(*keys)
        keys.each_with_object({}) { |k, memo| memo[k] = read(k) }
      end

      def size
        @document_store.size
      end
    end
  end
end
