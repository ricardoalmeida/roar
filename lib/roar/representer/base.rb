require 'representable'

module Roar
  module Representer
    module Base
      def self.included(base)
        base.class_eval do
          include Representable
          extend ClassMethods
          
          class << self
            alias_method :property, :representable_property
            alias_method :collection, :representable_collection
          end
        end
      end
      
        
      module ClassMethods
        # Creates a representer instance and fills it with +attributes+.
        def from_attributes(attributes) # DISCUSS: better move to #new? how do we handle the original #new then?
          new.tap do |representer|
            yield representer if block_given?
            attributes.each { |p,v| representer.public_send("#{p}=", v) }
          end
        end
      end
      
      
      # Convert representer's attributes to a nested attributes hash.
      def to_attributes
        {}.tap do |attributes|
          self.class.representable_attrs.each do |definition|
            value = public_send(definition.accessor)
            
            if definition.typed?
              value = definition.apply(value) do |v|
                v.to_attributes  # applied to each typed attribute (even in collections).
              end
            end
            
            attributes[definition.accessor] = value
          end
        end
      end
    end
  end
end
