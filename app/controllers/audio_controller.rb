class AudioController < ApplicationController

  def index
    @sounds = Audio.find(:all, :order => "position ASC")
    render :layout => false
  end

end
