# frozen_string_literal: true

module Decidim
  module Admin
    module BulkInvitations
      class BulkInvitationsController < Decidim::Admin::ApplicationController
        def create
          enforce_permission_to :create, :admin_user

          form = form(BulkInviteUsersForm).from_params(params)

          BulkInviteUsers.call(form) do
            on(:ok) do
              flash[:notice] = t(".success")
            end

            on(:invalid) do
              flash[:alert] = t(".error", error: form.errors.full_messages.first)
            end
          end

          redirect_to decidim_admin.officializations_path
        end
      end
    end
  end
end
