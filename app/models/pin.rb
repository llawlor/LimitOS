class Pin < ApplicationRecord
  belongs_to :device

  # options for pin type
  PIN_TYPES = ['servo', 'digital']

end
