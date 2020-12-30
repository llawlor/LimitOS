# == Schema Information
#
# Table name: synchronized_pins
#
#  id                 :bigint           not null, primary key
#  pin_id             :integer
#  synchronization_id :integer
#  device_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  value              :string(255)
#

require 'rails_helper'

RSpec.describe SynchronizedPin, type: :model do

  # lazy loaded variables
  let(:user) { FactoryBot.create(:user) }
  let(:device) { FactoryBot.create(:device, user: user) }
  let(:pin) { FactoryBot.create(:pin, pin_type: 'input', pin_number: 22, device: device) }
  let(:synchronization) { FactoryBot.create(:synchronization, device: device) }
  let(:synchronized_pin) { FactoryBot.create(:synchronized_pin, device: device, pin: pin, synchronization: synchronization, value: 'on') }

  describe '#opposite_value' do
    it "returns 'off'" do
      expect(synchronized_pin.opposite_value).to eq('off')
    end

    it "returns 'on'" do
      synchronized_pin.update(value: 'off')
      expect(synchronized_pin.opposite_value).to eq('on')
    end

    it "returns '0'" do
      synchronized_pin.update(value: '90')
      expect(synchronized_pin.opposite_value).to eq('0')
    end

    it "returns 'nil'" do
      synchronized_pin.update(value: '0')
      expect(synchronized_pin.opposite_value).to eq(nil)
    end
  end

end
