# frozen_string_literal: true

class UpdateDegrowthOrganizationLocales < ActiveRecord::Migration[5.2]
  def change
    organization = Decidim::Organization.find_by(host: "degrowth")

    if organization
      organization.update(available_locales: ["en"], default_locale: "en")

      organization.searchable_resources.where(locale: "nl").delete_all
    end
  end
end
