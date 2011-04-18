module AssignsHelper
  def remove_assign_link assign
    link_to(image_tag('icons/cross.png', :title => 'remove'), assign_path(assign), :confirm => "Are you sure to remove #{assign.counter.name}?", :method => :delete)
  end
end
