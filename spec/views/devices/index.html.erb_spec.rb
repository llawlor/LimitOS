require 'rails_helper'

RSpec.describe "devices/index", type: :view do
  before(:each) do
    assign(:devices, [
      Device.create!(),
      Device.create!()
    ])
  end

  it "renders a list of devices" do
    render
  end
end
