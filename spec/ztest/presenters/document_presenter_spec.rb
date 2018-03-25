require 'spec_helper'

require 'ztest/index/index_schema'
require 'ztest/presenters/document_presenter'

# TODO:: Special character removal in strings

RSpec.describe Ztest::Presenters::DocumentPresenter do

  let(:hash) do
    {
      '_id' => 123,
      'name' => 'blarg',
      'subject' => 'my subject'
    }
  end

  let(:presenter) { Ztest::Presenters::DocumentPresenter.new(schema, hash) }

  describe '#type' do
    let(:schema) { ::Ztest::Index::IndexSchema.new('my_index') }

    it 'used schema type' do
      expect(presenter.index_name).to eq('my_index')
    end
  end

  describe '#pretty_title' do
    let(:schema) { ::Ztest::Index::IndexSchema.new('my_index') }



    it 'used name field by default' do
      expect(presenter.pretty_title).to eq('blarg (123)')
    end

    it 'used schema defined over_ride' do
      schema.title_field = 'subject'
      expect(presenter.pretty_title).to eq('my subject (123)')

    end

  end


end
