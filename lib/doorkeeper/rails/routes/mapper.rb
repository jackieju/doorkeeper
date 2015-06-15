module Doorkeeper
  module Rails
    class Routes
      class Mapper
        def initialize(mapping = Mapping.new)
            # p "==>>4#{@mapping.inspect}", 30
            
            # p "==>>3#{mapping.inspect}"
            
          @mapping = mapping
          
        end

        def map(&block)
            # p "==>>1#{@mapping.inspect}"
            
            # p "instance_eval:#{block.inspect}"
          self.instance_eval(&block) if block
          # p "==>>2#{@mapping.inspect}"
          @mapping
        end

        def controllers(controller_names = {})
          @mapping.controllers.merge!(controller_names)
        end

        def skip_controllers(*controller_names)
          @mapping.skips = controller_names
        end

        def as(alias_names = {})
          @mapping.as.merge!(alias_names)
        end
      end
    end
  end
end
