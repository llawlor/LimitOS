require "rails_helper"

RSpec.describe PinsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/devices/1/pins").to route_to("pins#index", :device_id => "1")
    end

    it "routes to #new" do
      expect(:get => "/devices/1/pins/new").to route_to("pins#new", :device_id => "1")
    end

    it "routes to #show" do
      expect(:get => "/devices/1/pins/1").to route_to("pins#show", :id => "1", :device_id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/devices/1/pins/1/edit").to route_to("pins#edit", :id => "1", :device_id => "1")
    end

    it "routes to #create" do
      expect(:post => "/devices/1/pins").to route_to("pins#create", :device_id => "1")
    end

    it "routes to #update via PUT" do
      expect(:put => "/devices/1/pins/1").to route_to("pins#update", :id => "1", :device_id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/devices/1/pins/1").to route_to("pins#update", :id => "1", :device_id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/devices/1/pins/1").to route_to("pins#destroy", :id => "1", :device_id => "1")
    end

  end
end
