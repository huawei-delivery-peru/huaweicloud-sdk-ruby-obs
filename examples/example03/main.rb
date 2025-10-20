require 'huaweicloud-cdn'  
require 'dotenv/load'

access_key = ENV['HUAWEICLOUD_ACCESS_KEY']
secret_key = ENV['HUAWEICLOUD_SECRET_KEY']
region     = ENV['HUAWEICLOUD_REGION']

client = CDN::Client.new(region: region,access_key: access_key, secret_key: secret_key)
client.create_invalidation('https://qas.plan4us.pe/','https://qas.plan4us.pe/FILES/')#,'https://qas.plan4us.pe/FILES/'