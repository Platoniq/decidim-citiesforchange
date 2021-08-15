# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Meetings::MeetingsController.class_eval do
    before_action :redirect_to_conference_program, only: [:index], if: lambda {
      current_organization.redirect_meetings_index_to_conference_program? &&
        current_participatory_space.is_a?(Decidim::Conference)
    }

    private

    def redirect_to_conference_program
      redirect_to decidim_conferences.conference_conference_program_path(
        current_participatory_space,
        current_component,
        filter: filter_params
      )
    end
  end
end
