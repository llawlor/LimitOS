# == Schema Information
#
# Table name: pins
#
#  id         :integer          not null, primary key
#  device_id  :integer
#  name       :string(255)
#  pin_type   :string(255)
#  pin_number :integer
#  min        :integer
#  max        :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Pin, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
