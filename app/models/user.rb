# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  message    :string
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  thread_id  :string
#  user_id    :string
#
class User < ApplicationRecord
end
