require 'ext/spreadsheet'

class God::TagsController < God::BaseController

  before_filter do
    @nav = @check.current ? :control : :archive
  end

  def index

  end
  
end