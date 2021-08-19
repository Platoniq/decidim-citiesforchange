# frozen_string_literal: true

module Decidim
  module Admin
    module BulkInvitations
      class BulkInviteUsers < Rectify::Command
        DEST_FOLDER = "tmp/uploads"

        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) unless @form.valid?

          if upload_csv_file
            bulk_invite_users_async
            broadcast(:ok)
          else
            broadcast(:invalid)
          end
        end

        private

        def upload_csv_file
          FileUtils.move(@form.csv_file.tempfile.path, destination_path)
        rescue StandardError
          false
        end

        def destination_path
          @destination_path ||= begin
            timestamp = Time.current.to_s(:db).parameterize(separator: "_")
            basename = File.basename(@form.csv_file.original_filename, ".csv").parameterize(separator: "_")
            filename = "#{timestamp}_#{basename}.csv"

            Dir.mkdir(DEST_FOLDER) unless File.directory?(DEST_FOLDER)
            File.join(DEST_FOLDER, filename)
          end
        end

        def bulk_invite_users_async
          BulkInviteUsersJob.perform_later(
            destination_path,
            @form.csv_col_sep,
            @form.send_new_invitations?,
            @form.current_organization.id
          )
        end
      end
    end
  end
end
