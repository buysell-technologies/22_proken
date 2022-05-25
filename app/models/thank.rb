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
class Thank < ApplicationRecord
end
