# huaweicloud-sdk-ruby-obs
# 1. Build and install manually
```
$>gem build obs.gemspec
  Successfully built RubyGem
  Name: huaweicloud-obs
  Version: 1.0.0
  File: huaweicloud-obs-1.0.0.gem
$>gem install ./huaweicloud-obs-1.0.0.gem
Successfully installed huaweicloud-obs-1.0.0
1 gem installed
$>ls -l /usr/local/bundle/gems/huaweicloud-obs-1.0.0/
total 20
-rwxrwxrwx 1 root root 11558 Sep 26 16:38 LICENSE
-rwxrwxrwx 1 root root  1002 Sep 26 16:38 README.md
drwxr-xr-x 3 root root  4096 Sep 26 16:38 lib
```

# 2. Create Bucket
![alt text](https://github.com/huawei-delivery-peru/huaweicloud-sdk-ruby-obs/blob/main/images/1.png?raw=true)

![alt text](https://github.com/huawei-delivery-peru/huaweicloud-sdk-ruby-obs/blob/main/images/2.png?raw=true)

![alt text](https://github.com/huawei-delivery-peru/huaweicloud-sdk-ruby-obs/blob/main/images/3.png?raw=true)

![alt text](https://github.com/huawei-delivery-peru/huaweicloud-sdk-ruby-obs/blob/main/images/4.png?raw=true)

# 3. OBS Client

A Ruby gem for interacting with S3-compatible object storage services.

## 3.1 Installation

Without GemFile:
```
gem install specific_install
gem specific_install -l https://github.com/huawei-delivery-peru/huaweicloud-sdk-ruby-obs.git
```

Add this line to your Gemfile:

```ruby
gem 'huawei-obs', github: 'huawei-delivery-peru/huaweicloud-sdk-ruby-obs'
```
