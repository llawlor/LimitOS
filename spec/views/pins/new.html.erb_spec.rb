require 'rails_helper'

RSpec.describe "pins/new", type: :view do
  before(:each) do
    assign(:pin, Pin.new(
      :device => nil,
      :name => "MyString",
      :pin_type => "MyString",
      :pin_number => 1,
      :min => 1,
      :max => 1
    ))
  end

  it "renders new pin form" do
    render

    assert_select "form[action=?][method=?]", pins_path, "post" do

      assert_select "input#pin_device_id[name=?]", "pin[device_id]"

      assert_select "input#pin_name[name=?]", "pin[name]"

      assert_select "input#pin_pin_type[name=?]", "pin[pin_type]"

      assert_select "input#pin_pin_number[name=?]", "pin[pin_number]"

      assert_select "input#pin_min[name=?]", "pin[min]"

      assert_select "input#pin_max[name=?]", "pin[max]"
    end
  end
end
