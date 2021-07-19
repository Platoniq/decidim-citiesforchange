# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::ApplicationController.include(InstanceHelper)
  Decidim::ViewModel.include(InstanceHelper)
end
