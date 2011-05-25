module ApplicationHelper
  def loading_submit(f, label=nil, options={})
    new_c = (options[:class] || "") + " once"
    f.submit(label, options.merge(:class => new_c)) + notispan
  end

  def loading_link label='', url='', options={}
    new_c = (options[:class] || "") + " once"
    link_to(label, url, options.merge(:class => new_c)) + notispan
  end
  
  def action_link con=false, label='', url='', options={}
    if con
      return loading_link(label, url, options)
    end
    raw("<a href='#' class='button gray'>#{label}</a>")
  end
  
  private
  def notispan
    raw("<span style='display:none;'>#{image_tag('loader.gif')} Processing...</span>")
  end
end
