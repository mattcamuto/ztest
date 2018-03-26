require 'spec_helper'
require 'json'

require 'ztest'

RSpec.describe 'integration' do
  context 'with supplied zd fixtures' do
    let(:search_index) { Ztest::Demo::DemoIndexBuilder.new.load_and_create_index }

    describe '#find' do
      it 'finds existing documents' do
        aggregate_failures 'expected well defined documents' do
          expect(search_index.find(:organizations, 119)['name']).to eq ('Multron')
          expect(search_index.find(:organizations, 120)['created_at']).to eq ('2016-01-15T04:11:08 -11:00')
          expect(search_index.find(:users, 3)['name']).to eq ('Ingrid Wagner')
          expect(search_index.find(:tickets, '81bdd837-e955-4aa4-a971-ef1e3b373c6d')['subject']).to eq ('A Catastrophe in Pakistan')
        end
      end

      it 'raises with a missing document' do
        expect {
          search_index.find(:users, 8675309)
        }.to raise_error /Document not found, index=users id=8675309/
      end
    end

    describe '#search' do
      def matched_search_ids(index, field, *value)
        search_index.search(index, field , *value).map {|doc| doc['_id']}
      end

      it 'raises with ill defined index' do
        expect {
          search_index.search(:bad, 'field' , 'value')
        }.to raise_error /InvertIndex: index 'bad' does not exist!/
      end

      it 'finds expected documents' do
        aggregate_failures 'expected well defined documents' do
          expect(matched_search_ids(:organizations, :details , *['Artisan'])).to eq([111, 115, 116, 117])

          expected_ticket_ids = %w(436bf9b0-1147-4c0a-8439-6f79833bff5b 01e60325-abe4-44d8-a821-035e15637428)
          expect(matched_search_ids(:tickets, :subject , 'Korea')).to eq(expected_ticket_ids)
        end
      end
    end

    describe '#index_keys' do
      it 'has well defined keys' do
        aggregate_failures 'well defined keys' do
          expected_user_keys = %w(_id url external_id name alias created_at active verified shared locale timezone last_login_at email phone signature organization_id tags suspended role)
          expect(search_index.index_keys(:users)).to match_array(expected_user_keys)

          expected_ticket_keys = %w(_id url external_id created_at type subject description priority status submitter_id assignee_id organization_id tags has_incidents due_at via)
          expect(search_index.index_keys(:tickets)).to match_array(expected_ticket_keys)

          expected_organization_keys = %w(_id url external_id name domain_names created_at details shared_tickets tags)
          expect(search_index.index_keys(:organizations)).to match_array(expected_organization_keys)
        end
      end
    end
  end
end
