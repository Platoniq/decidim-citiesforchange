# frozen_string_literal: true

module Decidim
  module Admin
    module BulkInvitations
      class BulkInviteUsersJob < ApplicationJob
        queue_as :bulk_invitations

        def perform(filename, col_sep, send_new_invitations, organization_id)
          return unless File.exist?(filename)

          csv_data = read_csv(filename, col_sep)

          return if csv_data.empty?

          old_users = find_users(csv_data.emails, organization_id)

          new_users = if send_new_invitations
                        new_emails = csv_data.emails - old_users.pluck(:email)

                        create_new_users(csv_data.fields, new_emails, organization_id)

                        find_users(new_emails, organization_id)
                      end

          users_to_invite = new_users || old_users

          send_invitations_async(users_to_invite.ids)

          File.delete(filename)
        end

        private

        def read_csv(filename, col_sep)
          CsvData.new(filename, col_sep)
        end

        def find_users(emails, organization_id)
          Decidim::User.where(email: emails, decidim_organization_id: organization_id)
        end

        def create_new_users(csv_rows, new_emails, organization_id)
          UserBulkInsert.new(csv_rows, new_emails, organization_id).insert_all
        end

        def send_invitations_async(user_ids)
          user_ids.each do |user_id|
            SendBulkInvitationsEmailJob.perform_later(user_id)
          end
        end
      end
    end
  end
end
