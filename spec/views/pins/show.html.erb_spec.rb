require 'rails_helper'

RSpec.describe "pins/show", type: :view do
  before(:each) do
    @pin = assign(:pin, Pin.create!(
      :device => nil,
      :name => "Name",
      :pin_type => "Pin Type",
      :pin_number => 2,
      :min => 3,
      :max => 4
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Pin Type/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
  end
end
