module ApplicationHelper
  def loading_submit(f, label=nil, options={})
    new_c = (options[:class] || "") + " once"
    message = options.delete(:message)
    f.submit(label, options.merge(:class => new_c)) + notispan(message)
  end

  def loading_submit_without_loading label, path, options={}
    new_c = (options[:class] || "") + " once"
    
    link_to(label, path, options) + notispan(message)
  end

  def loading_link label='', url='', options={}
    new_c = (options[:class] || "") + " once"
    message = options.delete(:message)
    link_to(label, url, options.merge(:class => new_c)) + notispan(message)
  end

  def action_link con=false, label='', url='', options={}
    if con
      return loading_link(label, url, options)
    end
    raw("<a href='#' class='button gray'>#{label}</a>")
  end
  
  private
  def notispan message=nil
    message ||= 'Processing...'
    raw("<span style='display:none;'>#{image_tag('loader.gif')} #{message}</span>")
  end
end
