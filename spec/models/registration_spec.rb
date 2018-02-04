# == Schema Information
#
# Table name: registrations
#
#  id         :integer          not null, primary key
#  auth_token :string(6)
#  device_id  :integer
#  expires_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Registration, type: :model do

  # lazy loaded variables
  let (:registration) { FactoryGirl.build(:registration) }

  describe '#set_auth_token' do
    it 'adds an auth_token before create' do
      expect(registration.auth_token).to be_nil
      registration.save
      expect(registration.auth_token).to_not be_nil
    end

    it 'regenerates an auth_token if already taken' do
      existing_auth_token = Registration.create.auth_token
      allow(SecureRandom).to receive(:base58).and_return(existing_auth_token, '123456')
      registration.save
      expect(registration.auth_token).to eq('123456')
    end
  end

end
