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
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
