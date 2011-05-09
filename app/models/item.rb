class Item < ActiveRecord::Base
  scope :missing_cost, where(:cost.eq % nil | :cost.eq % 0).includes(:inventories).where(:inventories => (:quantity.gt % 0 | :result_qty.gt % 0))
  scope :need_adjustment, where(:from_al.eq % false | :data_changed.eq % true)
  
  belongs_to :item_group
  has_many :inventories
  
  before_update :mark_flag
  def mark_flag
    self.data_changed = true
  end
  
  def group_name
    self.item_group.try(:name)
  end
  
  def counted_total_qty
    self.inventories.map(&:result_qty).sum
  end
  
  def adj_max_quantity
    (self.max_quantity && self.max_quantity > 0 && counted_total_qty > self.max_quantity) ? counted_total_qty : nil
  end
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
#  from_al       :boolean         default(FALSE)
#  al_cost       :float
#  data_changed  :boolean         default(FALSE)
#  is_active     :boolean
#  inittags      :text
#

