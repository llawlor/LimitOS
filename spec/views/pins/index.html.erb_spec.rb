require 'rails_helper'

RSpec.describe "pins/index", type: :view do
  before(:each) do
    assign(:pins, [
      Pin.create!(
        :device => nil,
        :name => "Name",
        :pin_type => "Pin Type",
        :pin_number => 2,
        :min => 3,
        :max => 4
      ),
      Pin.create!(
        :device => nil,
        :name => "Name",
        :pin_type => "Pin Type",
        :pin_number => 2,
        :min => 3,
        :max => 4
      )
    ])
  end

  it "renders a list of pins" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Pin Type".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
