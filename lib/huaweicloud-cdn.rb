# lib/huaweicloud-cdn.rb
require_relative 'cdn/version'
require_relative 'cdn/client'

# Para compatibilidad y fácil acceso
module CDN
  Client = CDN::Client::HuaweiCDNClient
  
  def self.configure(&block)
    CDN::Client.configure(&block)
  end
end