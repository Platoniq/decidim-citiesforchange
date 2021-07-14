Rails.application.config.to_prepare do
  Decidim::ApplicationController.include(InstanceHelper)
  Decidim::ViewModel.include(InstanceHelper)
end