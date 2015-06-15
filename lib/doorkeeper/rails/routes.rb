require 'doorkeeper/rails/routes/mapping'
require 'doorkeeper/rails/routes/mapper'

module Doorkeeper
  module Rails
    class Routes
      module Helper
        # TODO: options hash is not being used
        def use_doorkeeper(options = {}, &block)
          Doorkeeper::Rails::Routes.new(self, &block).generate_routes!(options)
        end
      end

      def self.install!
        ActionDispatch::Routing::Mapper.send :include, Doorkeeper::Rails::Routes::Helper
      end

      attr_accessor :routes

      def initialize(routes, &block)
        @routes, @block = routes, block
        # p "@block=#{@block.inspect}", 30
      end

      def generate_routes!(options)
           # p "block3:#{@block.inspect}"
        @mapping = Mapper.new.map(&@block)
        p "mapping3:#{@mapping.inspect}"
        routes.scope options[:scope] || 'oauth', as: 'oauth' do
          map_route(:authorizations, :authorization_routes)
          map_route(:tokens, :token_routes)
          map_route(:tokens, :revoke_routes)
          map_route(:applications, :application_routes)
          map_route(:authorized_applications, :authorized_applications_routes)
          map_route(:token_info, :token_info_routes)
          map_route(:cda, :cda_routes)
          
        end
        
      end

      private

      def map_route(name, method)
        unless @mapping.skipped?(name)
          send method, @mapping[name]
        end
      end

      def authorization_routes(mapping)
        routes.resource(
          :authorization,
          path: 'authorize',
          only: [:create, :destroy],
          as: mapping[:as],
          controller: mapping[:controllers]
        ) do
          routes.get '/:code', action: :show, on: :member
          routes.get '/', action: :new, on: :member
        end
      end

      def token_routes(mapping)
        routes.resource(
          :token,
          path: 'token',
          only: [:create], as: mapping[:as],
          controller: mapping[:controllers]
        )
      end

      def revoke_routes(mapping)
          # p "mapping2:#{mapping.inspect}"
          
        routes.post 'revoke', controller: mapping[:controllers], action: :revoke
      end
      def cda_routes(mapping)
          p "mapping:#{mapping.inspect}"
        routes.post 'cda', controller: mapping[:controllers], action: :index
        routes.get 'cda', controller: mapping[:controllers], action: :index
        
      end
      def token_info_routes(mapping)
        routes.resource(
          :token_info,
          path: 'token/info',
          only: [:show], as: mapping[:as],
          controller: mapping[:controllers]
        )
      end

      def application_routes(mapping)
        routes.resources :doorkeeper_applications, controller: mapping[:controllers], as: :applications, path: 'applications'
      end

      def authorized_applications_routes(mapping)
        routes.resources :authorized_applications, only: [:index, :destroy], controller: mapping[:controllers]
      end
    end
  end
end
