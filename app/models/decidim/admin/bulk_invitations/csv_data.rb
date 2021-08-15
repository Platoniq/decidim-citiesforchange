# frozen_string_literal: true

require "csv"

module Decidim
  module Admin
    module BulkInvitations
      class CsvData
        def initialize(filename, col_sep)
          @filename = filename
          @col_sep = col_sep
        end

        def headers
          @headers ||= CSV.foreach(@filename, options).first.headers
        end

        def fields
          @fields ||= begin
            fields = []

            CSV.foreach(@filename, options) do |row|
              fields << row.fields unless row.fields.any?(&:blank?)
            end

            fields
          end
        end

        def emails
          @emails ||= fields.map(&:last)
        end

        delegate :empty?, to: :fields

        private

        def options
          {
            col_sep: @col_sep,
            encoding: "UTF-8",
            headers: true,
            header_converters: :symbol,
            skip_blanks: true
          }
        end
      end
    end
  end
end
