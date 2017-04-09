require 'rails_helper'

RSpec.describe "devices/new", type: :view do
  before(:each) do
    assign(:device, Device.new())
  end

  it "renders new device form" do
    render

    assert_select "form[action=?][method=?]", devices_path, "post" do
    end
  end
end
