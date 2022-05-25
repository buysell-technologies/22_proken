# == Schema Information
#
# Table name: thanks
#
#  id         :bigint           not null, primary key
#  count      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :string
#
require 'rails_helper'

RSpec.describe Thank, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
