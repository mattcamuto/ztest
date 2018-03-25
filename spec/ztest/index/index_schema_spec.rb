require 'spec_helper'
require 'ztest/index/index_schema'

RSpec.describe Ztest::Index::IndexSchema do
  let(:schema) { Ztest::Index::IndexSchema.new('the_name') }

  it { expect(schema.name).to eq('the_name')}

  context 'searchable_keys' do
    describe '#document_keys' do
      it 'gets all and dedupes keys' do
        schema.add_document_keys(%w(a b c))
        schema.add_document_keys(%w(b c))
        expect(schema.document_keys).to eq (%w(a b c))
      end

    end
  end

end
