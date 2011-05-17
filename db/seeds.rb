# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
unless Role.find_by_code("controller")
  Role.create(:code => "controller", :description => "Organizer")
end

unless Role.find_by_code("organizer")
  Role.create(:code => "organizer", :description => "Organizer")
end

unless Role.find_by_code("dataentry")
  Role.create(:code => "dataentry", :description => "Data Entry")
end

unless Role.find_by_code("audit")
  Role.create(:code => "audit", :description => "External Audit")
end

unless Role.find_by_code("mgt")
  Role.create(:code => "mgt", :description => "Mgt Overview")
end

unless Admin.find_by_username('controller')
  Role.find_by_code("controller").admins.create(
    :username => 'controller',
    :email => 'controller@vxmt.com.cn',
    :password => '123456',
    :password_confirmation => '123456'
  )
end
