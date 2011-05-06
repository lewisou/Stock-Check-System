class Location < ActiveRecord::Base
  has_many :assigns
  has_many :counters, :through => :assigns
  
  belongs_to :check
  has_many :inventories
  has_many :tags, :through => :inventories
  
  before_save :ensure_is_remote_has_a_value
  def ensure_is_remote_has_a_value
    if self.is_remote.nil?
      self.is_remote = true
    end
  end

  before_update :mark_flag
  def mark_flag
    self.data_changed = true
  end
  
  attr_accessor :new_assigns, :curr_check

  before_save :refresh_assigns
  def refresh_assigns
    unless @new_assigns.nil? || @curr_check.nil?
      self.assigns.in_check(@curr_check.id).each {|ass| ass.destroy }
      self.assigns << @new_assigns
    end
  end

  def description
    "#{desc1} #{desc2} #{desc3}"
  end

  def available_counters count
    rs = Counter.all - self.assigns.where(:count => 3 - count).map(&:counter)
    rs - self.assigns.where(:count => count).map(&:counter)
  end
  
  def has_available_counters?
    Counter.count - self.assigns.count > 0
  end

  def counter_names count
    self.assigns.where(:count => count).map(&:counter).map(&:name).join(", ")
  end

end







# == Schema Information
#
# Table name: locations
#
#  id           :integer         not null, primary key
#  code         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  is_available :boolean
#  is_active    :boolean
#  check_id     :integer
#  from_al      :boolean         default(FALSE)
#  data_changed :boolean         default(FALSE)
#  desc1        :text
#  desc2        :text
#  desc3        :text
#  is_remote    :boolean
#

