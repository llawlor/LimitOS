require 'rails_helper'

RSpec.describe "pins/edit", type: :view do
  before(:each) do
    @pin = assign(:pin, Pin.create!(
      :device => nil,
      :name => "MyString",
      :pin_type => "MyString",
      :pin_number => 1,
      :min => 1,
      :max => 1
    ))
  end

  it "renders the edit pin form" do
    render

    assert_select "form[action=?][method=?]", pin_path(@pin), "post" do

      assert_select "input#pin_device_id[name=?]", "pin[device_id]"

      assert_select "input#pin_name[name=?]", "pin[name]"

      assert_select "input#pin_pin_type[name=?]", "pin[pin_type]"

      assert_select "input#pin_pin_number[name=?]", "pin[pin_number]"

      assert_select "input#pin_min[name=?]", "pin[min]"

      assert_select "input#pin_max[name=?]", "pin[max]"
    end
  end
end
