# frozen_string_literal: true

require "csv"

module Decidim
  module Admin
    module BulkInvitations
      class SendBulkInvitationsEmailJob < ApplicationJob
        queue_as :bulk_invitations

        def perform(user_id)
          user = Decidim::User.find(user_id)

          user.confirm

          deliver_email(user)
        end

        private

        def deliver_email(user)
          token = user.send(:set_reset_password_token)

          Decidim::DecidimDeviseMailer.reset_password_instructions(user, token).deliver_now
        end
      end
    end
  end
end
