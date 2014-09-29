# -*- encoding : utf-8 -*-
class Profile < ActiveResource::Base
  self.site = CAMPUS_REST_WEBAPP + '/agents/:agent_id'
  self.format = :xml

  def to_html_option(current_profile_id, profiles, show_current = true)
    (!show_profile?(profiles, id) || (!show_current && id == current_profile_id)) ? '' : "<option value=\"#{id}\"#{" selected=\"selected\"" if id == current_profile_id }>#{appDescription}-#{userType}-#{userSubType}</option>"
  end

  private

  def show_profile?(profiles, id)
    cooperation_profiles = profiles.select{|p| p.id.include?('COOPERACIO')}
    member_profiles = profiles.select{|p| p.id.include?('MEMBRE')}
    return true unless (id.include?("MEMBRE") && (cooperation_profiles.nil? || profiles.size!=cooperation_profiles.size+member_profiles.size))
    #return true unless id.include? "MEMBRE"

    environment =id.split('-')[0]
    environment_profiles = profiles.group_by(&:appId).select{|p| p.first.eql?(environment)}
    environment_profiles && environment_profiles.first && environment_profiles.first.last ? environment_profiles.first.last.size <= 1 : true
  end

end
