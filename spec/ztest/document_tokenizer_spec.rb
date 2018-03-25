require 'spec_helper'

# TODO:: Special character removal in strings


RSpec.describe Ztest::DocumentTokenizer do

  context 'with a hash input' do
    let(:tokenizer) { Ztest::DocumentTokenizer.new }
    context 'empty hash' do
      it 'returns no tokens' do
        expect(tokenizer.tokenize({})).to eq([])
      end
    end

    context 'with a single level hash' do
      let(:the_document) do
        {
          '_id' => 123,
          'name' => 'matty c',
          'groups' => [
            'rolling StoneS',
            'metallica',
            'three doors down',
            'u2'
          ],
          some_true: true,
          some_int: 134,
          domain: 'pets.com',
          url: 'http://www.example.com/',
          created_at: '2016-07-31T02:37:50 -10:00',
          dupes: 'something really duplicate duplicate    lIkE duplicate',
          'empty_str' => '',
          'empty_with_spaces ' => '    ',
          'nil_oh_nil' => nil
        }
      end

      context 'with no special treatment' do
        let(:tokenizer) { Ztest::DocumentTokenizer.new }

        it 'unrolls all tokens, bound to keys' do
          expected = {
            '_id' => [123],
            'name' => %w(matty c),
            'groups' => %w(rolling StoneS metallica three doors down u2),
            'some_true' => ['true'],
            'some_int' => [134],
            'domain' => ['pets.com'],
            'url' => ['http://www.example.com/'],
            'created_at' => ['2016-07-31T02:37:50', '-10:00'],
            'dupes' => %w(something really duplicate duplicate lIkE duplicate),
            'empty_str' => [],
            'empty_with_spaces ' => [],
            'nil_oh_nil' => []
          }

          expect(tokenizer.tokenize(the_document)).to eq(expected)
        end
      end

      context 'filtering and parsing' do
        context 'custom filters' do
          let(:the_document) do
            {
              '_id' => 123,
              'groups' => [
                'three doors down',
                'u2',
                'bad_WorD',
                'hello'
              ],
              some_int: 134,
              domain: ''
            }
          end

          it 'applies arbitrary filters' do
            expected = {
              '_id' => [123],
              'some_int' => [134],
              'groups' => %w(three doors down hello ),
              'domain' => []
            }

            f1 = ->(value) { value.length < 3 }
            f2 = ->(value) { %w(bad_word).include?(value.downcase) }

            tokenizer = Ztest::DocumentTokenizer.new(filters: [f1, f2])
            expect(tokenizer.tokenize(the_document)).to eq(expected)
          end

          context 'with nil filter' do
            xit 'fails'
          end
        end

        context 'parsing' do
          let(:the_document) do
            {
              '_id' => 123,
              'domains' => [
                'bla.com',
                'u2.com',
                'webvan.com',
                'hel.lo'
              ],
              site: 'matt.net',
              some_int: 134,
              time1: '2016-01-10T14:12:34 -10:00',
              time2: '2016-01-10T12:12:34 -10:00'
            }
          end

          it 'can apply custom parsers, per field' do
            # These parsers are simple by design, For demonstrable purposes for zen test
            domain_parser = ->(value) { [value.split('.').first, value]}
            time_parser = ->(value) { Time.parse(value).utc.to_s.split(' ')[0, 2]}

            parsers = {
              'domains' => domain_parser,
              'site' => domain_parser,
              'time1' => time_parser,
              'time2' => time_parser
            }


            tokenizer = Ztest::DocumentTokenizer.new(parsers: parsers)
            expected = {
              '_id' => [123],
              'domains' => ['bla', 'bla.com', 'u2', 'u2.com', 'webvan', 'webvan.com', 'hel', 'hel.lo'],
              'site' => ['matt', 'matt.net'],
              'some_int' => [134],
              'time1' => ['2016-01-11', '00:12:34'],
              'time2' => ['2016-01-10', '22:12:34']
            }
            expect(tokenizer.tokenize(the_document)).to eq(expected)
          end
        end
      end
    end
  end


  context 'exceptional' do
    let(:tokenizer) { Ztest::DocumentTokenizer.new }

    it 'raises if document is nil' do
      expect {
        tokenizer.tokenize(nil)
      }.to raise_error(::Ztest::DocumentTokenizer::TokenizeError, 'Nil Document, Must be hash.')
    end

    context 'not nil, not a hash' do
      shared_examples 'not hash acceptable' do |document|
        it "raises when instance of #{document.class}, not a hash" do
          expect {
            expect(tokenizer.tokenize(document))
          }.to raise_error(::Ztest::DocumentTokenizer::TokenizeError, 'Document Invalid, Must be hash.')
        end
      end

      it_should_behave_like 'not hash acceptable', 123
      it_should_behave_like 'not hash acceptable', ' '
      it_should_behave_like 'not hash acceptable', 'blarg'
      it_should_behave_like 'not hash acceptable', [1, 2, 3, 4]
    end
  end

end
