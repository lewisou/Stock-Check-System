class ItemInfo < ActiveRecord::Base
  belongs_to :item

  before_save :refresh_remaining
  def refresh_remaining
    self.item.reload

    self.res_qty = self.item.inventories.sum("result_qty") || 0
    self.remaining = ((self.item.max_quantity || 0) == 0) ? nil : (self.item.max_quantity - self.res_qty)
  end

  before_save :refresh_remote_info
  def refresh_remote_info
    self.sum_remote_frozen_qty = self.item.inventories.remote_s.sum(:quantity) || 0
    self.sum_remote_result_qty = self.item.inventories.remote_s.sum(:result_qty) || 0
    self.sum_remote_frozen_value = self.item.inventories.remote_s.sum(:frozen_value) || 0
    self.sum_remote_result_value = self.item.inventories.remote_s.sum(:result_value) || 0
  end
end


#

# == Schema Information
#
# Table name: item_infos
#
#  id                      :integer         not null, primary key
#  res_qty                 :integer
#  item_id                 :integer
#  created_at              :datetime
#  updated_at              :datetime
#  remaining               :integer
#  sum_remote_frozen_qty   :integer
#  sum_remote_result_qty   :integer
#  sum_remote_frozen_value :float
#  sum_remote_result_value :float
#

