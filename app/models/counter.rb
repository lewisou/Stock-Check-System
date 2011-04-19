class Counter < ActiveRecord::Base
  has_many :assigns, :class_name => "::Assign"
  has_many :locations, :through => :assigns

  attr_accessor :new_assigns, :curr_check

  before_save :refresh_assigns
  def refresh_assigns
    unless @new_assigns.nil? || @curr_check.nil?
      self.assigns.in_check(@curr_check.id).each {|ass| ass.destroy }
      self.assigns << @new_assigns
    end
  end

  def check_location_by_count? location, count
    self.assigns.where(:count => count).map(&:location).include?(location)
  end

  def check_location? location
    self.locations.include?(location)
  end


  def self.counted_bys
    rs = []
    2.times {|time| 
      Counter.all.each {|counter| 
        rs << ["Count #{time + 1} - #{counter.name}", "#{counter.id}_#{time + 1}"]
      }
    }
    rs
  end
end


# == Schema Information
#
# Table name: counters
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  description :text
#

