# lib/cdn/client.rb
require 'httparty'
require 'json'

module CDN
  module Client
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

    class HuaweiCDNClient
      include HTTParty
      format :json

      attr_reader :region, :access_key, :secret_key, :token, :timeout

      def initialize(region: nil, access_key: nil, secret_key: nil, timeout: 60)
        @region = region || CDN::Client.config&.region
        @access_key = access_key || CDN::Client.config&.access_key
        @secret_key = secret_key || CDN::Client.config&.secret_key
        @timeout = timeout || CDN::Client.config&.timeout
        @token = nil

        validate_credentials!
      end

      # Crea una invalidación de cache en el CDN
      # @param paths [Array<String>] URLs a invalidar
      # @return [Hash] Respuesta de la API
      def create_invalidation(*paths)
        authenticate unless @token
        
        url = "https://cdn.myhuaweicloud.com/v1.0/cdn/content/refresh-tasks"
        
        body = {
          refresh_task: {
            type: "directory",
            mode: "detect_modify_refresh",
            zh_url_encode: false,
            urls: paths
          }
        }.to_json

        headers = {
          'Content-Type' => 'application/json',
          'X-Auth-Token' => @token
        }

        options = {
          headers: headers,
          body: body,
          timeout: @timeout
        }

        response = self.class.post(url, options)
        
        unless response.success?
          raise Error, "Failed to create invalidation: HTTP #{response.code} - #{response.body}"
        end

        response.parsed_response
      end

      # Alias para create_invalidation
      def invalidate_cache(*paths)
        create_invalidation(*paths)
      end

      # Alias para create_invalidation
      def refresh_cache(*paths)
        create_invalidation(*paths)
      end

      private

      # Autentica con Huawei Cloud IAM y obtiene el token
      def authenticate
        url = "https://iam.#{region}.myhuaweicloud.com/v3/auth/tokens"
        
        body = {
          auth: {
            identity: {
              methods: ["hw_ak_sk"],
              hw_ak_sk: {
                access: {
                  key: access_key
                },
                secret: {
                  key: secret_key
                }
              }
            }
          }
        }.to_json

        headers = {
          'Content-Type' => 'application/json'
        }

        options = {
          headers: headers,
          body: body,
          timeout: @timeout
        }

        response = self.class.post(url, options)
        
        unless response.success?
          raise Error, "Authentication failed: HTTP #{response.code} - #{response.body}"
        end

        @token = response.headers['x-subject-token']
        
        unless @token
          raise Error, "No X-Subject-Token received in authentication response"
        end

        @token
      end

      # Valida que las credenciales estén presentes
      def validate_credentials!
        if @region.nil? || @region.empty?
          raise Error, "Region is required"
        end

        if @access_key.nil? || @access_key.empty?
          raise Error, "Access key is required"
        end

        if @secret_key.nil? || @secret_key.empty?
          raise Error, "Secret key is required"
        end
      end
    end
  end
end