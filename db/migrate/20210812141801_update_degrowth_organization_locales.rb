# frozen_string_literal: true

class UpdateDegrowthOrganizationLocales < ActiveRecord::Migration[5.2]
  def change
    organization = Decidim::Organization.find_by(host: "conference.degrowth.nl")

    if organization
      organization.update(available_locales: ["en"], default_locale: "en")

      Decidim::SearchableResource.where(organization: organization, locale: "nl").delete_all
    end
  end
end
