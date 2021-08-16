# frozen_string_literal: true

require "csv"

module Decidim
  module Admin
    module BulkInvitations
      class SendBulkInvitationsEmailJob < ApplicationJob
        queue_as :bulk_invitations

        def perform(user_id)
          user = Decidim::User.find(user_id)

          deliver_email(user)
        end

        private

        def deliver_email(user)
          invited_by = nil
          options = {}

          user.invite!(invited_by, options)
        end
      end
    end
  end
end
