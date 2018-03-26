require 'spec_helper'
require 'ztest/document_validator'

RSpec.describe Ztest::DocumentValidator do
  let(:validator) { Ztest::DocumentValidator.new }

  describe '#validate!' do
    context 'positive' do
      it 'does not fail' do
        hash = { '_id' => 1, 'external_id' => '1111' }
        expect(validator.validate!(hash)).to eq(true)
      end
    end

    context 'exceptional' do
      it 'fails if not a hash' do
        hash = instance_double(Class)
        expect(hash).to receive(:respond_to?).with(:to_hash)
        expect {
          validator.validate!(hash)
        }.to raise_error(Ztest::DocumentValidator::InvalidDocumentError,
                         'DocumentValidator: Document must respond to to_hash')
      end

      it 'fails with nested hash' do
        hash = { '_id' => 1, 'external_id' => '1111', ppp: { a: :b } }
        expect {
          validator.validate!(hash)
        }.to raise_error(Ztest::DocumentValidator::InvalidDocumentError,
                         'DocumentValidator: Nested hashes not allowed, key=ppp')
      end

      it 'fails if missing required fields' do
        hash = { '_id' => 1}
        expect {
          validator.validate!(hash)
        }.to raise_error(Ztest::DocumentValidator::InvalidDocumentError,
                         'DocumentValidator: Required filed external_id missing, fields [_id,external_id] required.')
      end
    end
  end
end

