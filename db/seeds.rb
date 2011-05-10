# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

unless cor = Role.find_by_code("controller")
  cor = Role.create(:code => "controller")
end

unless Role.find_by_code("admin")
  Role.create(:code => "admin")
end

unless Role.find_by_code("counter")
  Role.create(:code => "counter")
end

unless Admin.find_by_username('admin')
  cor.admins.create(
    :username => 'admin',
    :email => 'admin@vxmt.com.cn',
    :password => '123456',
    :password_confirmation => '123456'
  )
end
