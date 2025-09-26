load 'huaweicloud-obs'

access_key = ENV['ACCESS_KEY']
secret_key = ENV['SECRET_KEY']

obs = OBS.new(access_key, secret_key, "la-south-2")
response = obs.putObject('file01.txt', 'bucket-huawei-demo', './file.txt')
response = obs.putObject('archivos/file02.txt', 'bucket-huawei-demo', './file.txt')
response = obs.deleteObject('archivos/file02.txt', 'bucket-huawei-demo')
response = obs.getObject('file01.txt', 'bucket-huawei-demo','./file01.txt')