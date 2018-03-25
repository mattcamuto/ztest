require 'spec_helper'
require 'ztest/finders/has_many_finder'

RSpec.describe Ztest::Finders::HasManyFinder do
  let(:search_index) { instance_double('Ztest::Index::SearchIndex') }
  let(:finder) { Ztest::Finders::HasManyFinder.new(:tickets, :submitter_id, search_index) }

  describe '#composite_index_key' do
    it 'has expected key' do
      expect(finder.composite_index_key).to eq('tickets-submitter_id')
    end
  end

  describe '#load_related_objects' do
    context 'invalid collection ' do
      it 'returns [] if empty input' do
        expect(finder.load_related_objects([])).to eq([])
      end
    end

    context 'with a collection' do
      let(:collection) do
        [
          { '_id' => 123 },
          { '_id' => 456 },
          { '_id' => 456 },
          { '_id' => 888 }
        ]
      end

      it 'queries the search_index' do
        expect(search_index).to receive(:search).with(:tickets, :submitter_id, *[123, 456, 888])
        finder.load_related_objects(collection)
      end
    end
  end

  describe '#filter_loaded_objects' do
    let(:child_collection) do
      [
        { '_id' => 555, 'submitter_id' => 123 },
        { '_id' => 666, 'submitter_id' => 555 },
        { '_id' => 777, 'submitter_id' => 666 },
        { '_id' => 888, 'submitter_id' => 123 }
      ]
    end

    it 'filters from a collection' do
      expected_hash = [{ '_id' => 555, 'submitter_id' => 123 }, { '_id' => 888, 'submitter_id' => 123 }]
      aggregate_failures 'integer or string key' do
        expect(finder.filter_loaded_objects(child_collection, 123)).to eq(expected_hash)
        expect(finder.filter_loaded_objects(child_collection, '123')).to eq(expected_hash)
      end
    end

    it 'returns [] if empty' do
      aggregate_failures 'empty collection' do
        expect(finder.filter_loaded_objects(nil, 123)).to eq([])
        expect(finder.filter_loaded_objects([], '123')).to eq([])
      end
    end
  end
end



