require 'bundler'
Bundler.setup

require 'test/unit'
require 'minitest/spec'

require 'roar/representer/base'
require 'roar/representer/feature/hypermedia'
require 'roar/representer/feature/http_verbs'

require 'stringio'  # FIXME. remove for 3.0.4.
require 'builder'

  module TestModel
    def self.included(base)
      base.extend ClassMethods
    end
    
    
    module ClassMethods
      def accessors(*names)
        names.each do |name|
          attr_accessor name
        end
      end
    end
    
    attr_accessor :attributes
    
    def initialize(attributes={})
      @attributes = attributes
    end
  end


class Item
  include TestModel
  accessors :value
  
  def self.model_name
    "item"
  end
end

class Position
  include TestModel
  accessors :id, :item
  
  def self.model_name
    :order
  end
end

class Order
  include TestModel
  accessors :id, :items
  
  def self.model_name
    :order
  end
end

require "test_xml/mini_test"
require "roar/representer/xml"
