require "obs/version"

require 'net/http'
require 'json'
require 'openssl'
require 'digest/md5'
require 'time'
require 'base64'

module OBS
    class Client
        attr_accessor :access_key, :secret_key, :region

        def initialize(access_key, secret_key, region)
            @access_key = access_key
            @secret_key = secret_key
            @region = region
        end

        # Get a file in the specified bucket in OBS.
        #
        # @param file_name [String] The name of the file in the bucket.
        # @param bucket_name [String] The name of the bucket where the file is located.
        # @return [Net::HTTPResponse] The response from the OBS server.
        def getObject(file_name, bucket_name, local_file_path = nil)
            uri = URI("https://#{bucket_name}.obs.#{@region}.myhuaweicloud.com/#{file_name}")

            request = Net::HTTP::Get.new(uri)
            date_n = Time.now.httpdate
            signature = sign(http_verb: 'GET', date: date_n, resource: "/#{bucket_name}/#{file_name}")
            
            request['Authorization'] = "OBS #{@access_key}:#{signature}"
            request['Date'] = date_n

            response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
                http.request(request)
            end

            if response.code == '200'
                if local_file_path
                    # Guardar el archivo localmente
                    File.binwrite(local_file_path, response.body)
                    #puts "DEBUG GET: Archivo guardado en: #{local_file_path}"
                    return true
                else
                    # Devolver el contenido del archivo
                    #puts "DEBUG GET: Archivo descargado (#{response.body.bytesize} bytes)"
                    return response.body
                end
            else
                puts "DEBUG GET: Error: #{response.code} - #{response.body}"
                return false
            end

            response
        end

        # Uploads a file to the specified bucket in OBS.
        #
        # @param file_name [String] The name of the file uploadeded to the bucket.
        # @param bucket_name [String] The name of the bucket where the file will be uploaded.
        # @param file_dir [String] The local directory path of the file to be uploaded.
        # @return [Net::HTTPResponse] The response from the OBS server.
        def putObject(file_name, bucket_name, file_dir)
            file = File.read(file_dir)
            uri = URI("https://#{bucket_name}.obs.#{@region}.myhuaweicloud.com/#{file_name}")
            
            request = Net::HTTP::Put.new(uri)
            content_md5 = Digest::MD5.base64digest(file)
            date_n = Time.now.httpdate

            # Determinar content-type basado en la extensión del archivo
            content_type = get_content_type(file_name)

            #signature = sign(http_verb: 'PUT', content_md5: content_md5, date: date_n, resource: "/#{bucket_name}/#{file_name}")
            # Firmar incluyendo el content-type
            signature = sign(
                http_verb: 'PUT', 
                content_md5: content_md5, 
                content_type: content_type,  # ¡Importante!
                date: date_n, 
                resource: "/#{bucket_name}/#{file_name}"
            )
            
            request['Authorization'] = "OBS #{@access_key}:#{signature}"
            request['Date'] = date_n
            request['Content-MD5'] = content_md5
            request['Content-Type'] = content_type  # ¡Este header faltaba!
            request.body = file

            response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
                http.request(request)
            end

            response
        end

        # Delete a file in the specified bucket in OBS.
        #
        # @param file_name [String] The name of the file in the bucket.
        # @param bucket_name [String] The name of the bucket where the file is located.
        # @return [Net::HTTPResponse] The response from the OBS server.
        def deleteObject(file_name, bucket_name)
            uri = URI("https://#{bucket_name}.obs.#{@region}.myhuaweicloud.com/#{file_name}")

            request = Net::HTTP::Delete.new(uri)
            date_n = Time.now.httpdate

            signature = sign(
                http_verb: 'DELETE',
                content_md5: '',
                content_type: '',
                date: date_n, 
                resource: "/#{bucket_name}/#{file_name}"
            )
            
            request['Authorization'] = "OBS #{@access_key}:#{signature}"
            request['Date'] = date_n

            response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
                http.request(request)
            end

            response
        end

        def sign(http_verb:"", content_md5:"", content_type:"", date:"", resource:"")
            # El string to sign debe coincidir EXACTAMENTE con lo que muestra OBS
            string_to_sign = [
                http_verb,
                content_md5,
                content_type,
                date,
                resource
            ].join("\n")
            
            # Firmar con HMAC-SHA1 usando el secret key
            hmac = OpenSSL::HMAC.digest(
                OpenSSL::Digest.new('sha1'), 
                @secret_key,  # ¡Asegúrate de tener @secret_key definido!
                string_to_sign
            )
            
            # Codificar en Base64
            signature = Base64.strict_encode64(hmac)
            #puts "DEBUG: Signature calculada: #{signature}"
            
            signature
        end

        # Método auxiliar para determinar content-type
        def get_content_type(filename)
            case File.extname(filename).downcase
            when '.txt' then 'text/plain'
            when '.html' then 'text/html'
            when '.json' then 'application/json'
            when '.xml' then 'application/xml'
            when '.pdf' then 'application/pdf'
            when '.jpg', '.jpeg' then 'image/jpeg'
            when '.png' then 'image/png'
            when '.zip' then 'application/zip'
            else 'application/octet-stream'
            end
        end
    end
end