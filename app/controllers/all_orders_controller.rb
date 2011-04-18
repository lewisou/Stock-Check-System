class AllOrdersController < ApplicationController
  def generate
    curr_check.generate_xls

    if curr_check.save
      redirect_to checks_path, :notice => 'Excels generated.'
    else
      redirect_to checks_path, :error => 'Failed to generate Excels.'
    end
  end
end
