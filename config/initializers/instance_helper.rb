# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::ApplicationController.helper(InstanceHelper)
  Decidim::ViewModel.include(InstanceHelper)
end
