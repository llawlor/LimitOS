require 'rails_helper'

RSpec.describe "devices/edit", type: :view do
  before(:each) do
    @device = assign(:device, Device.create!())
  end

  it "renders the edit device form" do
    render

    assert_select "form[action=?][method=?]", device_path(@device), "post" do
    end
  end
end
