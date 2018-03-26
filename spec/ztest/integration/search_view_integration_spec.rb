require 'spec_helper'
require 'json'

require 'ztest/index/search_index'
require 'ztest/document_stores/local_document_store'
require 'ztest/document_validator'
require 'ztest/document_tokenizer'
require 'ztest/index/invert_index'
require 'ztest/demo/demo_index_builder'
require 'ztest/demo/demo_view_builder'

RSpec.describe 'view integration' do

  let(:search_index) { Ztest::Demo::DemoIndexBuilder.new.load_and_create_index }
  let(:demo_view_builder) { Ztest::Demo::DemoViewBuilder.new(search_index) }

  context 'view integration' do
    it 'presents expected elements and children' do
      objects = demo_view_builder.search_and_present('users', 'tags', *['Roland', 'Bellfountain'])
      expect(objects).to have(2).documents

      first = objects.first
      expect(first.index_name).to eq('users')
      expect(first.pretty_title).to eq('Lee Davidson (20)')

      expected_table_data = [["_id", 20],
                             ["active", false],
                             ["alias", "Miss Hayes"],
                             ["created_at", "2016-04-07T11:08:24 -10:00"],
                             ["email", "hayesdavidson@flotonic.com"],
                             ["external_id", "1c8b9696-b5c5-4f5a-b077-5d85dd8b22f4"],
                             ["last_login_at", "2014-05-04T09:18:56 -10:00"],
                             ["locale", "en-AU"],
                             ["name", "Lee Davidson"],
                             ["organization_id", 104],
                             ["phone", "9544-832-980"],
                             ["role", "end-user"],
                             ["shared", true],
                             ["signature", "Don't Worry Be Happy!"],
                             ["suspended", true],
                             ["tags", ["Riegelwood", "Snyderville", "Roland", "National"]],
                             ["timezone", "Norway"],
                             ["url", "http://initech.zendesk.com/api/v2/users/20.json"],
                             ["verified", false],
                             ["tickets-submitter_id.0", "A Catastrophe in Sao Tome and Principe (7523607d-d45c-4e3a-93aa-419402e64d73)"],
                             ["tickets-submitter_id.1", "A Drama in Mongolia (e34262a7-df37-4715-a482-fb0acb5d0b46)"],
                             ["tickets-submitter_id.2", "A Catastrophe in Singapore (189eed9f-b44c-49f3-a904-2c482193996a)"],
                             ["tickets-assignee_id.0", "A Problem in Barbados (54f60187-6064-492a-9a4c-37fc21b4e300)"]]

      expect(first.table_data).to match_array(expected_table_data)
    end

    it 'associated on organization' do
      objects = demo_view_builder.search_and_present('organizations', 'details', 'MegaCörp')
      expect(objects).to have(3).documents

      objects = demo_view_builder.search_and_present('organizations', 'domain_names', 'artiq.com')
      expect(objects).to have(1).documents

      first = objects.first
      expect(first.index_name).to eq('organizations')
      expect(first.pretty_title).to eq('Noralex (113)')

      expected_table_data = [["_id", 113],
       ["created_at", "2016-04-09T08:45:29 -10:00"],
       ["details", "MegaCörp"],
       ["domain_names", ["artiq.com", "mazuda.com", "surelogic.com", "fuelworks.com"]],
       ["external_id", "67d9dbdb-a9c6-4a30-a003-202de05d09e2"],
       ["name", "Noralex"],
       ["shared_tickets", true],
       ["tags", ["Maldonado", "Hebert", "Poole", "Mcleod"]],
       ["url", "http://initech.zendesk.com/api/v2/organizations/113.json"],
       ["users-organization_id.0", "Tyler Bates (17)"],
       ["users-organization_id.1", "Burgess England (40)"],
       ["users-organization_id.2", "Pena Lang (53)"],
       ["users-organization_id.3", "Mari Deleon (57)"]]

      expect(first.table_data).to eq(expected_table_data)
    end
  end
end
