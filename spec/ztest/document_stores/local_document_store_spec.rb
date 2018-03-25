require 'spec_helper'
require 'ztest/document_stores/local_document_store'

RSpec.describe Ztest::DocumentStores::LocalDocumentStore do
  let(:document_store) { Ztest::DocumentStores::LocalDocumentStore.new }

  before do
    document_store.write('foo', { a: :b })
    document_store.write('bar', { c: :d })
    document_store.write('gaz', { e: :f })
  end

  it 'reports correct size' do
    expect(document_store.size).to eq(3)
  end

  describe '#write' do
    it 'increases count with addition' do
      expect {
        document_store.write('yzx', { e: :f })
        document_store.write('jkl', { e: :f })
      }.to change { document_store.size }.by(2)
    end

    it 'does not increase count on over-write' do
      expect {
        document_store.write('bar', { e: :f })
        document_store.write('bar', { j: :k })
      }.to_not change { document_store.size }
    end

    it 'fails if a non hash value' do
      aggregate_failures 'non hash objects' do
        expect {
          document_store.write('bar', 'ppp')
        }.to raise_error(Ztest::DocumentStores::LocalDocumentStore::DocumentError,
                         'LocalDocumentStore: value must respond_to?(:hash)')
        expect(document_store.read('bar')).to eq({ c: :d })
      end

      non_hashable = instance_double(Class)

      expect(non_hashable).to receive(:respond_to?).with(:to_hash) { false }
      expect {
        document_store.write('bar', non_hashable)
      }.to raise_error(Ztest::DocumentStores::LocalDocumentStore::DocumentError,
                       'LocalDocumentStore: value must respond_to?(:hash)')
      expect(document_store.read('bar')).to eq({ c: :d })
    end

  end

  describe '#read' do
    it 'decreases count with delete' do
      expect {
        document_store.delete('bar')
      }.to change { document_store.size }.by(-1)

    end

    it 'keeps same count when deleting a missing key' do
      expect {
        document_store.delete('xxx')
      }.to_not change { document_store.size }
    end
  end

  describe 'read' do
    it 'returns objects if exists' do
      aggregate_failures 'existing objects' do
        expect(document_store.read('foo')).to eq({ a: :b })
        expect(document_store.read('bar')).to eq({ c: :d })
      end
    end

    it 'returns nil on a miss' do
      expect(document_store.read('boogy')).to eq(nil)
    end

    it 'raises if the key is nil' do
      expect {
        document_store.read(nil)
      }.to raise_error(::Ztest::DocumentStores::KeyException, 'LocalDocumentStore does not support a nil key')
    end
  end

  describe '#read_multi' do
    it 'reads and returns as hash, preserving nils' do
      keys = %w(foo gaz ppp)
      expected = { 'foo' => { a: :b }, 'gaz' => { e: :f }, 'ppp' => nil }
      expect(document_store.read_multi(*keys)).to eq(expected)
    end
  end
end


