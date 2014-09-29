# -*- encoding : utf-8 -*-

DROPBOX_SETTINGS_UOC = {
      "key" => "miKey",
      "secret"=> "miSecret",
      "email"=> "email@gmail.com",
      "password"=> "mypassword123"
    }


CarrierWave.configure do |config|
  config.remove_previously_stored_files_after_update = false
  config.fog_credentials = {
        :provider               => 'AWS',                                      # required
        :aws_access_key_id      => 'amazon s3 access key',                     # required
        :aws_secret_access_key  => 'amazon s3 secret access key',              # required
        :region                 => 'us-west-1'                                 # optional, defaults to 'us-east-1'
      }
      config.fog_directory  = 'yourbucketname'                                 # required
      #config.fog_host       = 'http://yourbucketname.s3.amazonaws.com/'        # optional, defaults to nil
      config.fog_public     = false                                            # optional, defaults to true
      config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}           # optional, defaults to {}

end
