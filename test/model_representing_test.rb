require 'test_helper'
require 'roar/representer/feature/model_representing'

class ModelRepresentingTest < MiniTest::Spec
  describe "ModelRepresenting" do
    class ItemRepresenter
      include Roar::Representer::XML
      include Roar::Representer::Feature::ModelRepresenting # TODO: move to abstract!
      self.representation_name= :item
      property :value
    end
    
    class PositionRepresenter
      include Roar::Representer::XML
      include Roar::Representer::Feature::ModelRepresenting # TODO: move to abstract! 
      self.representation_name= :position
      property :id
      property :item, :as => ItemRepresenter
    end
    
    class OrderRepresenter
      include Roar::Representer::XML
      include Roar::Representer::Feature::ModelRepresenting # TODO: move to abstract!
      self.representation_name= :order
      property :id
      collection :items, :as => ItemRepresenter
    end
    
    describe "#definition_class" do
      it "returns ModelDefinition" do
        assert_equal Roar::Representer::Feature::ModelRepresenting::ModelDefinition, OrderRepresenter.send(:definition_class)
      end
      
    end
    
    describe "#for_model" do
      it "copies represented model attributes, nothing more" do
        @o = Position.new("id" => 1, "item" => Item.new("value" => "Beer"))
        @r = PositionRepresenter.for_model(@o)
        puts @r.inspect
        assert_kind_of PositionRepresenter, @r
        assert_equal 1, @r.id
        
        @i = @r.item
        assert_kind_of ItemRepresenter, @i
        assert_equal "Beer", @i.value
      end
      
      it "copies the model to @represented" do
        @o = Position.new("id" => 1, "item" => @i = Item.new("value" => "Beer"))
        
        @r = PositionRepresenter.for_model(@o)
        assert_equal @o, @r.represented
        assert_equal @i, @r.item.represented
      end
      
      
      it "works with Hyperlink attributes" do
        @c = Class.new(ItemRepresenter) do
          link :self do "http://self" end
        end
        
        assert_equal({"value"=>"Beer", "links"=>[{"rel"=>:self, "href"=>"http://self"}]}, @c.for_model(Item.new("value" => "Beer")).to_attributes)
      end
      
    end
    
    describe "#serialize_model" do
      it "skips empty :item" do
        @o = Position.new("id" => 1)
        assert_xml_equal "<position><id>1</id></position>", PositionRepresenter.serialize_model(@o)
      end
      
      it "skips empty [:items]" do
        assert_xml_equal "<order><id>1</id></order>", OrderRepresenter.serialize_model(Order.new("id" => 1))
      end
      
      it "serializes the model" do
        @o = Order.new("id" => 1, "items" => [Item.new("value" => "Beer")])
        assert_xml_equal %{
<order>
  <id>1</id>
  <item>
    <value>Beer</value>
  </item>
</order>}"", OrderRepresenter.serialize_model(@o)
      end
      
    end
    
    describe "#to_nested_attributes" do
      it "provides a AR-compatible hash" do
        @o = Order.new("id" => 1, "items" => [Item.new("value" => "Beer")])
        @r = OrderRepresenter.for_model(@o)
        
        OrderRepresenter.class_eval do
          include Roar::Representer::Feature::ActiveRecordMethods
        end
        ItemRepresenter.class_eval do
          include Roar::Representer::Feature::ActiveRecordMethods
        end
        assert_equal({"id" => 1, "items_attributes" => [{"value" => "Beer"}]}, @r.to_nested_attributes) # DISCUSS: overwrite #to_attributes.
      end
      
      it "doesn't include :links" do
        @o = Order.new("id" => 1, "items" => [Item.new("value" => "Beer")])
        
        
        
        OrderRepresenter.class_eval do
          include Roar::Representer::Feature::ActiveRecordMethods
          link :self do
        #    "bla"
          end
        end
        ItemRepresenter.class_eval do
          include Roar::Representer::Feature::ActiveRecordMethods
          link :self do
            
          end
        end
        @r = OrderRepresenter.for_model(@o)
        
        assert_equal({"id" => 1, "items_attributes" => [{"value" => "Beer"}]}, @r.to_nested_attributes) # DISCUSS: overwrite #to_attributes.
      end
    end
  end
end
