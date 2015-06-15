module Doorkeeper
  class CdaController < Doorkeeper::ApplicationController
    before_action :doorkeeper_authorize!
    def index
        p "cda!!!, params=#{params.inspect}"
        ret = {
            
        }
        render :json=>ret
    end


  end
end
