# -*- encoding : utf-8 -*-
class ExtendedSession < ActiveResource::Base
  self.site = CAMPUS_REST_WEBAPP
  self.element_name = 'extendedsession'
  self.format = :xml
end
