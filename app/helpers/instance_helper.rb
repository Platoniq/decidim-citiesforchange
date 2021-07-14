# frozen_string_literal: true

module InstanceHelper
  def instance_name
    if citiesforchange?
      :citiesforchange
    elsif degrowth?
      :degrowth
    end
  end

  def citiesforchange?
    if try(:organization)
      organization.host.match?("citiesforchange")
    elsif try(:current_organization)
      current_organization.host.match?("citiesforchange")
    end
  end

  def degrowth?
    if try(:organization)
      organization.host.match?("degrowth") || organization.host.match?("localhost") # DEBUG
    elsif try(:current_organization)
      current_organization.host.match?("degrowth") || current_organization.host.match?("localhost") # DEBUG
    end
  end
end
