require 'huaweicloud-obs'  
require 'dotenv/load'

access_key = ENV['HUAWEICLOUD_ACCESS_KEY']
secret_key = ENV['HUAWEICLOUD_SECRET_KEY']
region     = ENV['HUAWEICLOUD_REGION']

obs = OBS::Client.new(access_key, secret_key, region)
response = obs.putObject('file01.txt', 'huawei-demo-obs', './file.txt')
#response = obs.putObject('archivos/file02.txt', 'bucket-huawei-demo', './file.txt')
#response = obs.deleteObject('archivos/file02.txt', 'bucket-huawei-demo')
#response = obs.getObject('file01.txt', 'bucket-huawei-demo','./file01.txt')