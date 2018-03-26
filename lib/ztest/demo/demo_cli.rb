require 'tty-prompt'
require 'tty-table'

module Ztest
  module Demo
    class DemoCli

      def initialize
        @current_index = nil
        @prompt = TTY::Prompt.new
      end

      def run_loop
        intro
        loop do
          begin
            if @current_index == nil
              index_response = @prompt.select("Choose your index?", index_choices)
              exit if index_response == 'QUIT'
              @current_index = index_response
            else
              puts ' Please use Control-C at anytime to return home.'
              field = @prompt.select("Choose your field to search in index '#{@current_index}'?", current_search_keys)
              to_search = @prompt.ask("Value to search for field '#{field}'?")
              responses = search_view.search_and_present(@current_index, field, to_search)
              dump_responses(responses)
            end
          rescue TTY::Reader::InputInterrupt
            @current_index = nil
          end
        end
      end

      private

      def index_choices
        search_index.index_names.sort + ['QUIT']
      end

      def current_search_keys
        search_index.index_keys(@current_index)
      end

      def dump_responses(responses)
        responses.each do |resp|
          puts " "
          table = TTY::Table.new do |t|
            t << ['index_name', resp.index_name]
            t << ['pretty_name', resp.pretty_title]
            resp.table_data.each { |row| t << row }
          end
          puts table.render(:ascii, alignments: [:right, :left])
        end
      end

      def intro
        puts " "
        puts " ====== Welcome to simple search ======"
        puts " Please use arrows and keyboard to enter desired input."
        puts " Please use Control-C at anytime to return home."
        puts " QUIT choice will exit the application!"
        puts " "
      end

      def search_index
        @search_index ||= Ztest::Demo::DemoIndexBuilder.new.load_and_create_index
      end

      def search_view
        @search_view ||= Ztest::Demo::DemoViewBuilder.new(search_index)
      end
    end
  end
end
