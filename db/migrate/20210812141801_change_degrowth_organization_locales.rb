class ChangeDegrowthOrganizationLocales < ActiveRecord::Migration[5.2]
  def change
    organization = Decidim::Organization.find_by(host: "degrowth")
    attributes   = { available_locales: ["en"], default_locale: "en" }

    organization&.update(attributes)
  end
end
