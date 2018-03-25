# Basic tokenizer
# Converts all to string for this test.
# Custom filters and parsers are allowed.

module Ztest
  class DocumentTokenizer
    class TokenizeError < StandardError
    end

    # Filters remove on a rule.
    # Parsers can do non standard string parsing
    def initialize(parsers: {}, filters: [])
      @filters = filters
      @parsers = parsers
    end

    # Tokenize each document field and apply any given filters or parsers
    def tokenize(document)
      validate_document(document)
      return [] if document.empty?
      {}.tap do |hash|
        document.each_pair do |k, v|
          hash[k.to_s] = tokenize_value(k, v)
        end
      end
    end

    private

    # Simple tokenizing
    # For this excercise we assume input is number or string. Nothing complex.
    def tokenize_value(k, v)
      return [v] if v.is_a?(Numeric)
      Array(v).map do |v|
        parse(k.to_s, v.to_s).map do |str|
          filter_string(str)
        end
      end.flatten.compact
    end

    # Simple ability to parse a string with any object that can response to .call
    def parse(k, v)
      return [v] unless @parsers[k]
      @parsers[k].call(v)
    end

    # Apply simple set to filter out terms from a string base on filter chain
    # Note any failure is a fail. There is no chaining nor composition
    def filter_string(str)
      str.split(' ').reject do |v|
        @filters.any? { |filter| filter.call(v) }
      end
    end

    def validate_document(document)
      raise ::Ztest::DocumentTokenizer::TokenizeError.new('Nil Document, Must be hash.') if document.nil?
      raise ::Ztest::DocumentTokenizer::TokenizeError.new('Document Invalid, Must be hash.') unless document.is_a?(Hash)
    end

  end
end
