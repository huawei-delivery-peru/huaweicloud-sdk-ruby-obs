# lib/huaweicloud-cdn.rb
require 'net/http'
require 'json'
require 'uri'
require "obs/version"

module CDN
  class Error < StandardError; end

  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Configuration.new
    yield(config) if block_given?
  end

  class Configuration
    attr_accessor :region, :access_key, :secret_key, :timeout

    def initialize
      @timeout = 60
    end
  end

  class Client
    attr_reader :region, :access_key, :secret_key, :token, :timeout

    def initialize(region: nil, access_key: nil, secret_key: nil, timeout: 60)
      @region     = region     || CDN.config&.region
      @access_key = access_key || CDN.config&.access_key
      @secret_key = secret_key || CDN.config&.secret_key
      @timeout    = timeout    || CDN.config&.timeout || 60
      @token      = nil

      validate_credentials!
    end

    # Invalida URLs en el CDN.
    # @param paths [String, Array<String>] URLs a invalidar
    # @param type [String] "file" (default) para URLs exactas,
    #                      "directory" para invalidar todo el prefijo (URL debe terminar en /)
    # @return [Hash] Respuesta de la API
    def create_invalidation(*paths, type: "file")
      authenticate unless @token

      body = {
        refresh_task: {
          type: type,
          mode: "detect_modify_refresh",
          zh_url_encode: false,
          urls: paths.flatten
        }
      }.to_json

      response = post_json(
        "https://cdn.myhuaweicloud.com/v1.0/cdn/content/refresh-tasks",
        body,
        'X-Auth-Token' => @token
      )

      unless response.is_a?(Net::HTTPSuccess)
        raise Error, "Failed to create invalidation: HTTP #{response.code} - #{response.body}"
      end

      JSON.parse(response.body)
    end

    alias invalidate_cache create_invalidation
    alias refresh_cache    create_invalidation

    private

    # Autentica con Huawei Cloud IAM (AK/SK) y almacena el token.
    # El token tiene vigencia de 24 h; una nueva instancia del cliente
    # o una llamada explícita a authenticate renovará el token.
    def authenticate
      body = {
        auth: {
          identity: {
            methods: ["hw_ak_sk"],
            hw_ak_sk: {
              access: { key: @access_key },
              secret: { key: @secret_key }
            }
          }
        }
      }.to_json

      response = post_json(
        "https://iam.#{@region}.myhuaweicloud.com/v3/auth/tokens",
        body
      )

      unless response.is_a?(Net::HTTPSuccess)
        raise Error, "Authentication failed: HTTP #{response.code} - #{response.body}"
      end

      @token = response['x-subject-token']
      raise Error, "No X-Subject-Token received in authentication response" unless @token

      @token
    end

    def post_json(url_string, body, extra_headers = {})
      uri  = URI.parse(url_string)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = (uri.scheme == 'https')
      http.open_timeout = @timeout
      http.read_timeout = @timeout

      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      extra_headers.each { |k, v| request[k] = v }
      request.body = body

      http.request(request)
    end

    def validate_credentials!
      raise Error, "Region is required"     if @region.to_s.empty?
      raise Error, "Access key is required" if @access_key.to_s.empty?
      raise Error, "Secret key is required" if @secret_key.to_s.empty?
    end
  end
end