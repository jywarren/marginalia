class ModuleController < ApplicationController

  def index
    
  end
  
  def parse
    @title = params[:url].split('/').last
    render :template => 'module/index'
  end
  
end
