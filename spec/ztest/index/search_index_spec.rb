require 'spec_helper'
require 'ztest/index/search_index'
require 'ztest/document_stores/local_document_store'
require 'ztest/document_validator'
require 'ztest/document_tokenizer'
require 'ztest/index/invert_index'

RSpec.describe Ztest::Index::SearchIndex do

  describe '#add_document' do
    let(:document_store) { instance_double(Ztest::DocumentStores::LocalDocumentStore) }
    let(:document_validator) { instance_double(Ztest::DocumentValidator) }
    let(:document_tokenizer) { instance_double(Ztest::DocumentTokenizer) }
    let(:inverted_index) { instance_double(Ztest::Index::InvertIndex) }

    let(:search_index) { Ztest::Index::SearchIndex.new(document_store, document_validator, document_tokenizer, inverted_index) }

    context 'exceptional' do
      it 'raises with no schema index defined' do
        doc = { '_id' => 12 }
        expect {
          search_index.add_document(:matt_index, doc)
        }.to raise_error(Ztest::Index::SearchIndex::SearchIndexDocumentError,
                         'SearchIndex: The index schema matt_index is not defined')
      end

      context 'with schema index defined' do
        before { search_index.find_or_create_schema(:the_index) }
        let(:the_doc) { { '_id' => 123, 'key' => 'the value' } }

        it 're raises a validation error' do
          expect(document_validator).to receive(:validate!).and_raise ('foo')
          expect {
            search_index.add_document(:the_index, the_doc)
          }.to raise_error('foo')
        end

        it 're raises a tokenize error ' do
          the_doc = { '_id' => 123, 'key' => 'the value' }
          search_index.find_or_create_schema(:matt_index)
          expect(document_validator).to receive(:validate!).with(the_doc) { true }
          expect(document_tokenizer).to receive(:tokenize).and_raise('foobar')

          expect {
            search_index.add_document(:the_index, the_doc)
          }.to raise_error('foobar')
        end

        it 're raises a document store' do
          search_index.find_or_create_schema(:matt_index)
          expect(document_validator).to receive(:validate!).with(the_doc) { true }
          expect(document_tokenizer).to receive(:tokenize).with(the_doc) { { a: :b } }
          expect(document_store).to receive(:write).with('the_index:123', the_doc).and_raise('fff')
          expect {
            search_index.add_document(:the_index, the_doc)
          }.to raise_error('fff')
        end
      end
    end

    context 'a valid schema' do
      it 'can add a document' do
        the_doc = { '_id' => 123, 'key' => 'the value' }
        search_index.find_or_create_schema(:matt_index)
        expect(document_validator).to receive(:validate!).with(the_doc) { true }
        token_hash ={ '_id' => 123, 'boo' => ['a', 'b', 'c'] }

        expect(document_tokenizer).to receive(:tokenize).with(the_doc) { token_hash }
        expect(document_store).to receive(:write).with('matt_index:123', the_doc)
        expect(inverted_index).to receive(:add).with('matt_index', token_hash)
        search_index.add_document(:matt_index, the_doc)
      end
    end
  end

  describe '#find' do
    let(:document_store) { instance_double(Ztest::DocumentStores::LocalDocumentStore) }
    let(:document_validator) { instance_double(Ztest::DocumentValidator) }
    let(:document_tokenizer) { instance_double(Ztest::DocumentTokenizer) }
    let(:inverted_index) { instance_double(Ztest::Index::InvertIndex) }

    let(:search_index) { Ztest::Index::SearchIndex.new(document_store, document_validator, document_tokenizer, inverted_index) }

    context 'present_document' do
      it 'returns the document' do
        search_index.find_or_create_schema('myindex')
        expect(document_store).to receive(:read).with('myindex:1234').exactly(3).times { 'boo' }
        aggregate_failures 'simple name permutations' do
          expect(search_index.find('myindex', 1234)).to eq('boo')
          expect(search_index.find('  myinDex ', 1234)).to eq('boo')
          expect(search_index.find(:myindex, 1234)).to eq('boo')
        end
      end
    end

    context 'missing document' do
      it 'raises exceptions' do
        search_index.find_or_create_schema('myindex')
        expect(document_store).to receive(:read).with('myindex:1234') { nil }
        expect {
          search_index.find('myindex', 1234)
        }.to raise_error(Ztest::Index::SearchIndex::MissingDocumentError,
                         'SearchIndex: Document not found, index=myindex id=1234')
      end
    end

    context 'non existent index' do
      it 'raises' do
        expect {
          search_index.find('myindex', 1234)
        }.to raise_error(Ztest::Index::SearchIndex::SearchIndexDocumentError,
                         'SearchIndex: The index schema myindex is not defined')
      end
    end
  end

  describe '#search' do
  end

end
