# -*- encoding : utf-8 -*-
class Session < ActiveResource::Base
  self.site = CAMPUS_REST_WEBAPP
  self.format = :xml
end
