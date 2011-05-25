require 'json'

class Activity < ActiveRecord::Base
  @@lambdas = {
    "god/checks" => {
      "change_state" => lambda {|act| "[Control] Changed check status to #{act.get_rs['state']}"},
      "update" => lambda {|act| "[Basic Setup] Check #{act.get_rs['check']['description']}"},
      "create" => lambda {|act| "[Create Check Step #{act.get_rs['step']}]"}
    },
    "god/rechecks" => {
      "update" => lambda {|act| "[Re Check] uploaded recheck excel"}
    },
    "checks" => {
      "update" => lambda {|act| "[Re Import] uploaded reimport excel"}
    },
    "audit/tags" => {
      "update" => lambda {|act| "[Tag Audit] Tag # #{act.get_rs['id']} Audit #{act.get_rs["tag"]["audit"]}"}
    },
    "counts" => {
      "update" => lambda {|act| 
        if act.get_rs["tag"]["count_1"]
          "[DataEntry] Tag # #{act.get_rs['id']} Count_1 #{act.get_rs["tag"]["count_1"]}"
        elsif act.get_rs["tag"]["count_2"]
          "[DataEntry] Tag # #{act.get_rs['id']} Count_2 #{act.get_rs["tag"]["count_2"]}"
        elsif act.get_rs["tag"]["count_3"]
          "[DataEntry] Tag # #{act.get_rs['id']} Count_3 #{act.get_rs["tag"]["count_3"]}"
        end
      }
    },
    "accounts" => {
      "update" => lambda {|act| "[Account Update] #{act.get_rs["admin"]['username']}"}
    },
    "adm/tags" => {
      "update" => lambda {|act| "[Tag Change] Tag # #{act.get_rs['id']} Values #{act.get_rs['tag'].to_json}"},
      "destroy" => lambda {|act| "[Tag Delete] Tag # #{act.get_rs['id']}"}
    },
    "adm/counters" => {
      "update" => lambda {|act| "[Counter Assign] Counter #{act.get_rs['counter']['name']}"}
    },
    "adm/items" => {
      "update_price" => lambda {|act| "[Cost Update] Part Number #{Item.find(act.get_rs['id']).try(:code)} Cost #{act.get_rs['item']['cost']}"}
    },
    "locations" => {
      "update" => lambda {|act| "[Setup Remote] Location #{Location.find(act.get_rs['id']).try(:code)} Remote #{(act.get_rs['location']['is_remote'] == 1)}"}
    },
    "devise/sessions" => {
      "create" => lambda {|act| "[Log in]"}
    }
  }

  scope :valid_s, where(:met.not_eq => "GET")

  belongs_to :admin
  belongs_to :check

  before_save :gene_desc
  def gene_desc
    rs = get_rs
    
    if @@lambdas[rs["controller"]] && @@lambdas[rs["controller"]][rs["action"]]
      self.description = @@lambdas[rs["controller"]][rs["action"]].call(self)
    else
      self.description = rs.to_json
    end
  end

  def get_rs
    rs = JSON.parse(self.request || "{}")
    rm_values rs
    rs
  end

  def rm_values rs
    rs.delete('authenticity_token')
    rs.delete("utf8")
    rs.delete_if {|key, value| !(key.to_s =~ /.*password.*/).nil? }
    
    rs.each do |key, value|
      case value
      when Hash
        rm_values value
      end
    end
    rs
  end

end


# == Schema Information
#
# Table name: activities
#
#  id          :integer         not null, primary key
#  admin_id    :integer
#  request     :text
#  response    :text
#  ended_at    :datetime
#  finish      :boolean         default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#  description :text
#

