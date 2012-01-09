class LocationInfo < ActiveRecord::Base
  belongs_to :location

  before_update :refresh_sum_info
  def refresh_sum_info
    self.sum_frozen_qty = self.location.inventories.report_valid.sum(:quantity) || 0
    self.sum_result_qty = self.location.inventories.report_valid.sum(:result_qty) || 0
    self.sum_frozen_value = self.location.inventories.report_valid.sum(:frozen_value) || 0
    self.sum_result_value = self.location.inventories.report_valid.sum(:result_value) || 0
  end
end
