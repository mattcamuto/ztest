require 'spec_helper'
require 'ztest/index/invert_index'

RSpec.describe Ztest::Index::InvertIndex do
  let(:index) { Ztest::Index::InvertIndex.new }

  let(:a_doc1) { { '_id' => [123], 'food' => ['  taco ', 'burrito'], 'people' => %w(fred sally) } }
  let(:a_doc2) { { '_id' => 234, '  food  ' => %w(taco), 'people' => ['   '] } }
  let(:b_doc1) { { '_id' => [666], 'fun' => %w(stuff food taco), 'sports' => [nil] } }
  let(:b_doc2) { { '_id' => [777], 'fun' => %w(fishing), 'sports' => %w(soccer) } }

  before do
    index.add('a', a_doc1)
    index.add(:a, a_doc2)

    index.add('b', b_doc1)
    index.add(:b, b_doc2)
  end

  context 'read and write' do

    it 'finds indexed docs' do
      aggregate_failures do
        expect(index.lookup('a', :food, 'taco')).to eq([123, 234])
        expect(index.lookup('a', :food, 'burrito')).to eq([123])
        expect(index.lookup('a', :_id, '234')).to eq([234])
        expect(index.lookup('a', :_id, '999')).to eq([])
        expect(index.lookup('a', :people, '      ')).to eq([234])
        expect(index.lookup(:a, :people, '')).to eq([234])
        expect(index.lookup('a', ' pEople  ', nil)).to eq([234])

        expect(index.lookup('b', :fun, '  fishing  ')).to eq([777])
        expect(index.lookup(:b, :sports, '  soccer  ')).to eq([777])
      end
    end

    it 'return [] when no value has been indexed' do
      expect(index.lookup(:b, :sports, 'curling')).to eq([])
    end
  end

  context 'exceptional' do
    it 'raises with missing _id field' do
      expect {
        index.add(:b, { '_foo' => ['Bar'] })
      }.to raise_error(Ztest::Index::InvertIndex::IndexError, 'InvertIndex: _id field missing.')
    end

    it 'fails querying bobus index' do
      expect {
        index.lookup(' j ', :fun, '  fishing  ')
      }.to raise_error(Ztest::Index::InvertIndex::IndexError, "InvertIndex: index ' j ' does not exist!")
    end

    it 'fails querying bogus field' do
      expect {
        index.lookup(:b, :funny, '  fishing  ')
      }.to raise_error(Ztest::Index::InvertIndex::IndexError, "InvertIndex: key 'funny' for index 'b' does not exist!")
    end

  end

end
