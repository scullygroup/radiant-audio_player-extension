class Admin::AudioController < Admin::ResourceController
  model_class Audio

  def index
    self.models = model_class.find(:all, :order => "position ASC")
  end

  def reorder
    @audio = Audio.find(:all, :order => 'position')
  end
  
  def new
    @audio = Audio.new
    
    respond_to do |format|
      format.html
    end
  end
  
  def edit
    @audio = Audio.find(params[:id])
  end
  
  def create
    @audio = Audio.new(params[:audio])
    
    if @audio.save
      flash[:notice] = 'Audio was successfully created.'
      redirect_to :action => "index"
    else
      redirect_to audio_index_url
    end
  end
  
  def update
    @audio = Audio.find(params[:id])
    
    if @audio.update_attributes(params[:audio])
      flash[:notice] = 'Calendar was successfully updated.'
      redirect_to :action => "index"
    else
      redirect_to audio_index_url
    end
  end
  
  def destroy
    @audio = Audio.find(params[:id])
    
    if @audio.destroy
      flash[:notice] = 'Audio was removed.'
      redirect_to :action => "index"
    end
  end
  
  def update_order
    if request.post? && params.key?(:sort_order)
      list = params[:sort_order].split(',')
      list.size.times do |i|
        audio = Audio.find(list[i])
        audio.position = i + 1
        audio.save
      end
      redirect_to audio_index_url
    end
  end

end
