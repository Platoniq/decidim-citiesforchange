# frozen_string_literal: true

module Decidim
  module Admin
    module BulkInvitations
      class BulkInviteUsersForm < Decidim::Form
        CSV_COLUMNS = [:name, :email].freeze
        CSV_COL_SEPS = { comma: ",", semicolon: ";" }.freeze
        BULK_INVITE_MODE = { send_new_invitations: "send_new_invitations", resend_old_invitations: "resend_old_invitations" }.freeze

        class << self
          def csv_col_sep_options
            CSV_COL_SEPS.map do |i18n_key, value|
              [I18n.t("decidim.admin.bulk_invitations.form.csv_col_sep_options.#{i18n_key}"), value]
            end
          end

          def bulk_invite_mode_options
            BULK_INVITE_MODE.map do |i18n_key, value|
              [I18n.t("decidim.admin.bulk_invitations.form.bulk_invite_mode_options.#{i18n_key}"), value]
            end
          end
        end

        attribute :csv_file, ActionDispatch::Http::UploadedFile
        attribute :csv_col_sep, String
        attribute :bulk_invite_mode, String

        validates_presence_of :csv_file, :csv_col_sep, :bulk_invite_mode
        validates :csv_col_sep, inclusion: { in: CSV_COL_SEPS.values }
        validates :bulk_invite_mode, inclusion: { in: BULK_INVITE_MODE.values }
        validate :file_extension_must_be_csv
        validate :csv_headers_must_be_valid

        def send_new_invitations?
          bulk_invite_mode == "send_new_invitations"
        end

        private

        def file_extension_must_be_csv
          return if File.extname(csv_file.original_filename) == ".csv"

          errors.add(:csv_file, :invalid)
        end

        def csv_headers_must_be_valid
          return if CsvData.new(csv_file.tempfile.path, csv_col_sep).headers == CSV_COLUMNS

          errors.add(:csv_file, :invalid)
        end
      end
    end
  end
end
