# frozen_string_literal: true

module InstanceHelper
  def instance_name
    if citiesforchange?
      :citiesforchange
    elsif degrowth?
      :degrowth
    end
  end

  def instance_prefix_path(path)
    if citiesforchange?
      path
    else
      "#{instance_name}/#{path}"
    end
  end

  def citiesforchange?
    return if instance_organization.blank?
    
    instance_organization.host.match?("citiesforchange")
  end
  
  def degrowth?
    return if instance_organization.blank?
    
    instance_organization.host.match?("degrowth") || instance_organization.host.match?("localhost") # DEBUG
  end
  
  def instance_organization
    try(:organization) ||
    try(:current_organization) ||
    try(:@organization) ||
    try(:@current_organization)
  end
end
