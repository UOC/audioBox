class Classroom < ActiveResource::Base
  self.site = CAMPUS_REST_WEBAPP + '/agents/:agent_id'
  self.format = :xml
end