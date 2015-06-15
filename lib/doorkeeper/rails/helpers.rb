require 'http_post.rb'
module Doorkeeper
  module Rails
    module Helpers
      extend ActiveSupport::Concern

      def central_doorkeeper_authorize!(*scopes)
          # TODO should use https
          p "send request to http://localhost:3000/cda.."
          resp,data = https_post("http://localhost:3000/oauth/cda", params)
          p "==>resp:#{resp}, #{resp.code}; data=#{data}"
          
      end
      
      def doorkeeper_authorize!(*scopes)
          p "==>self:#{self}"
          p "===>scope:#{scopes}"
        @_doorkeeper_scopes = scopes.presence || Doorkeeper.configuration.default_scopes
        p "===>doorkeeper_authorize!2"

        if !valid_doorkeeper_token?
            p "===>doorkeeper_authorize!3"
            
          doorkeeper_render_error
          p "===>doorkeeper_authorize!4"
          
        end
      end

      def doorkeeper_unauthorized_render_options(error: nil)
      end

      def doorkeeper_forbidden_render_options(error: nil)
      end

      def valid_doorkeeper_token?
          p "doorkeeper_token=#{doorkeeper_token}"
        doorkeeper_token && doorkeeper_token.acceptable?(@_doorkeeper_scopes)
      end

      private

      def doorkeeper_render_error
        error = doorkeeper_error
        p "===>error:#{error}"
        headers.merge! error.headers.reject { |k| "Content-Type" == k }
        doorkeeper_render_error_with(error)
      end

      def doorkeeper_render_error_with(error)
        options = doorkeeper_render_options(error) || {}
        if options.blank?
          head error.status
        else
          options[:status] = error.status
          options[:layout] = false if options[:layout].nil?
          render options
        end
      end

      def doorkeeper_error
        if doorkeeper_invalid_token_response?
          OAuth::InvalidTokenResponse.from_access_token(doorkeeper_token)
        else
          OAuth::ForbiddenTokenResponse.from_scopes(@_doorkeeper_scopes)
        end
      end

      def doorkeeper_render_options(error)
        if doorkeeper_invalid_token_response?
          doorkeeper_unauthorized_render_options(error: error)
        else
          doorkeeper_forbidden_render_options(error: error)
        end
      end

      def doorkeeper_invalid_token_response?
        !doorkeeper_token || !doorkeeper_token.accessible?
      end

      def doorkeeper_token
        @_doorkeeper_token ||= OAuth::Token.authenticate(
          request,
          *Doorkeeper.configuration.access_token_methods
        )
      end
    end
  end
end
