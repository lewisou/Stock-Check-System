class Tag < ActiveRecord::Base
  belongs_to :location
  belongs_to :part

  search_methods :tolerance_q
  scope :tolerance_q, lambda { |quantity|
    {:conditions => ["(abs(tags.count_1 - tags.count_2) / tags.count_1) * 100 >= ? and tags.count_1 is not null", quantity.to_i.abs]}
  }

  search_methods :tolerance_v
  scope :tolerance_v, lambda { |value|
    {
      :joins => [:part],
      :conditions => ["abs(tags.count_1 * parts.cost - tags.count_2 * parts.cost) >= ?", value.to_f.abs]
    }
  }

  def final_count
    if self.count_1 == self.count_2
      return self.count_1 || 0
    end
    
    return self.count_3 || 0
  end

end


# == Schema Information
#
# Table name: tags
#
#  id          :integer         not null, primary key
#  count_1     :integer
#  count_2     :integer
#  count_3     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  location_id :integer
#  part_id     :integer
#

