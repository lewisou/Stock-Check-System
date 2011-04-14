class Item < ActiveRecord::Base
  belongs_to :item_group
  has_many :inventories
end





# == Schema Information
#
# Table name: items
#
#  id            :integer         not null, primary key
#  code          :string(255)
#  description   :text
#  cost          :float
#  created_at    :datetime
#  updated_at    :datetime
#  al_id         :integer
#  max_quantity  :integer
#  item_group_id :integer
#

