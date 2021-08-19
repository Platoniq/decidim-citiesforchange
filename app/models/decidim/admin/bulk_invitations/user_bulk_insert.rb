# frozen_string_literal: true

module Decidim
  module Admin
    module BulkInvitations
      class UserBulkInsert
        def initialize(csv_rows, new_emails, organization_id)
          @csv_rows = csv_rows
          @new_emails = new_emails
          @organization_id = organization_id
          @timestamp = Time.current.to_s(:db)
        end

        def insert_all
          ActiveRecord::Base.connection.execute(sql)
        end

        private

        def sql
          "INSERT INTO #{table_name} (#{columns}) VALUES #{values} ON CONFLICT DO NOTHING"
        end

        def table_name
          Decidim::User.table_name
        end

        def columns
          [
            :name,
            :email,
            :type,
            :nickname,
            :decidim_organization_id,
            :accepted_tos_version,
            :created_at,
            :updated_at
          ].join(", ")
        end

        def values
          @csv_rows
            .each_with_object([]).with_index(1) do |((name, email), array), index|
              array << "('#{[name, email, *missing_values(name, index)].join("', '")}')" if @new_emails.include?(email)
            end.join(", ")
        end

        def missing_values(name, index)
          [
            "Decidim::User",
            nicknamize(name, index),
            @organization_id,
            @timestamp,
            @timestamp,
            @timestamp
          ]
        end

        def nicknamize(name, index)
          nickname_length_range = (0...(Decidim::User.nickname_max_length - index.digits.size))

          "#{name.parameterize(separator: "_")[nickname_length_range]}#{index}"
        end
      end
    end
  end
end
