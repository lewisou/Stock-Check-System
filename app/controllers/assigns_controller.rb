class AssignsController < ApplicationController
  def new
    @location = curr_check.locations.find(params[:location_id])
    @assign = @location.assigns.build(params[:assign]);
  end
  
  def create
    @location = curr_check.locations.find(params[:location_id])
    @assign = @location.assigns.build(params[:assign])
    
    if @assign.save
      redirect_to counters_path, :notice => "Add user #{@assign.counter.name} to #{@location.code} check #{@assign.count} successfully."
    else
      render :new
    end
  end
  
  def destroy
    @assign = Assign.find(params[:id])

    if @assign.destroy
      redirect_to counters_path
    else
      render :status => :error
    end

  end
end
