# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :restrict_conference_program_access, if: -> { current_organization.restricted_conference_program_access? }

  private

  def restrict_conference_program_access
    return unless request.path.start_with?("/conferences")

    whitelisted_params = { "controller" => "decidim/conferences/conference_program", "action" => "show" }

    raise Decidim::ActionForbidden unless whitelisted_params <= params.to_unsafe_h
  end
end
