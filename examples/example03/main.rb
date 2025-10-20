require 'huaweicloud-cdn'  
require 'dotenv/load'

access_key = ENV['HUAWEICLOUD_ACCESS_KEY']
secret_key = ENV['HUAWEICLOUD_SECRET_KEY']
region     = ENV['HUAWEICLOUD_REGION']

client = CDN::Client.new(region: region,access_key: access_key, secret_key: secret_key)
client.create_invalidation('https://miempresaabc.link/','https://miempresaabc.link/FILES/')