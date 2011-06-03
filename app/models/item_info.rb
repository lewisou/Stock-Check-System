class ItemInfo < ActiveRecord::Base
  belongs_to :item

  before_save :refresh_remaining
  def refresh_remaining
    self.item.reload

    self.res_qty = self.item.inventories.sum("result_qty") || 0
    self.remaining = ((self.item.max_quantity || 0) == 0) ? nil : (self.item.max_quantity - self.res_qty)
  end
end


# == Schema Information
#
# Table name: item_infos
#
#  id         :integer         not null, primary key
#  res_qty    :integer
#  item_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  remaining  :integer
#

