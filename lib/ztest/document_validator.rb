# A Simple validator class. Any impl could be used with a search index, or chained for that
# matter. This sample validator assures only that the document has certain well defined keys,
# is a hash and has no nested hashes
module Ztest
  class DocumentValidator

    # A robust solution, is it not, for demo purposes
    REQUIRED_KEYS = %w(_id external_id)

    class InvalidDocumentError < StandardError
    end

    def validate!(document)
      validate_type(document)
      validate_not_nested(document)
      validate_required_fields(document)
      true
    end

    private

    def validate_type(document)
      return if document.respond_to?(:to_hash)
      raise_msg('DocumentValidator: Document must respond to to_hash')
    end

    def validate_not_nested(document)
      document.each_pair do |k, v|
        if v.is_a?(Hash)
          raise_msg("DocumentValidator: Nested hashes not allowed, key=#{k}")
        end
      end
    end

    def validate_required_fields(document)
      doc_keys = document.keys
      REQUIRED_KEYS.each do |k|
        unless doc_keys.include?(k)
          raise_msg("DocumentValidator: Required filed #{k} missing, fields [#{REQUIRED_KEYS.join(',')}] required.")
        end
      end
    end

    def raise_msg(message)
      raise InvalidDocumentError.new(message)
    end

  end
end
