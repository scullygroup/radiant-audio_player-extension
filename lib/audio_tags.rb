module AudioTags
  include Radiant::Taggable
  
  desc %Q{
    Embed the javascript code which is required to make the Flash player work.
  }
  tag 'tracks:script' do |tag|
    %Q{<script type="text/javascript" src="/javascripts/audio_player/audio-player.js"></script>}
  end
  
  desc %{The namespace for all audio tags}
  tag 'tracks' do |tag|
    tag.expand
  end
  
  desc %{Returns all audio tracks}
  tag 'tracks:each' do |tag|
    options = audio_find_options(tag)
    audio_tracks = []
    tag.locals.audio_tracks = Audio.find(:all, options)
    tag.locals.audio_tracks.each do |track|
      tag.locals.audio_track = track
      audio_tracks << tag.expand
    end
    audio_tracks
  end
  
  desc %{Find a track, by passing its id or title. This allows you to embed any audio track on any page of your choice, rather than depending on the Audio Page type.
    
    Note that this tag can be called from any page, with the attributes @id@ and @title@. In the context of a virtual child of AudioPage, the @<r:track/> tag will fetch the audio track based on the URL, disregrading any passed attributes.
    }
  tag 'track' do |tag|
    if tag.attr["id"] or tag.attr["title"]
      if id = tag.attr["id"]
        if track = Audio.find(id.to_i) rescue nil
          tag.locals.audio_track = track
          tag.expand
        end
      elsif title = tag.attr["title"]
        if track = Audio.find_by_title(title)
          tag.locals.audio_track = track
          tag.expand
        end
      end
    else
      "To accesss an audio track, you must supply an attribute with its id or title"
    end
  end
  
  # the following tags can all be accessed from the context of track or tracks:each
  # e.g. the following two examples should work:
  # <r:track id="1"/><r:title/></r:track> 
  # <r:tracks:each><r:title/></r:tracks:each>
  ["track", "tracks:each"].each do |context|
    
    [:title, :description].each do |column|
      desc %{  Renders contents unless the `#{column}' attribute is blank.}
      tag "#{context}:if_#{column}" do |tag|
        tag.expand unless tag.locals.audio_track[column].blank?
      end
    end
    
    desc %{Renders the title of the current audio track}
    tag "#{context}:title" do |tag|
      tag.locals.audio_track.title
    end

    desc %{Renders the tag contents only if the description is blank}
    tag "#{context}:unless_description" do |tag|
      tag.expand if tag.locals.audio_track.description.blank?
    end

    desc %{Renders the description of the current audio track}
    tag "#{context}:description" do |tag|
      tag.locals.audio_track.description_with_filter
    end

    desc %{Shows the path for this audio track}
    tag "#{context}:path" do |tag|
      tag.locals.audio_track.path
    end

    desc %{Shows the url for this audio track (ie, where it can be downloaded from)}
    tag "#{context}:url" do |tag|
      tag.locals.audio_track.url
    end

    desc %{Embed a flash player for this audio track}
    tag "#{context}:player" do |tag|
      %Q{<object type="application/x-shockwave-flash" data="/flash/audio_player/player.swf" id="audioplayer#{tag.locals.audio_track.id}" height="24" width="290">
<param name="movie" value="/flash/audio_player/player.swf">
<param name="FlashVars" value="#{player_params(tag.locals.audio_track)}">
<param name="quality" value="high">
<param name="menu" value="false">
<param name="wmode" value="transparent">
</object>}
    end
    
    desc %{
      Provides a link to the virtual page for this audio track.

      Note that this tag will only work if your site has one page of type AudioPage. 
      If you have more than one Audio Page, or no Audio Pages, then this tag won't work.
    }
    tag "#{context}:link" do |tag|
      track = tag.locals.audio_track
      if path = track.path
        text = tag.double? ? tag.expand : track.title
        %{<a href="#{path}" title="#{track.title}">#{text}</a>}
      else
        "You must have exactly 1 Audio page for this tag to work."
      end
    end
    
  end
  
  
  
  tag 'tracks:index_url' do |tag|
    movie_pages = Page.find_all_by_class_name("AudioPage")
    if movie_pages.size == 1
      movie_page = movie_pages.first.url
    else
      "You must have exactly 1 Audio page for this tag to work."
    end
  end
  
  private
  
  def player_params(audio_track)
    if config = AudioPlayerConfig.find_by_name("Site")
      player_params = config.parameters_for_player
    else
      player_params = ["autostart=no","loop=no"]
    end
    player_params += ["playerID=#{audio_track.id}","soundFile=#{audio_track.track.url}"]
    player_params.join("&amp;")
  end
  
  def audio_find_options(tag)
    attr = tag.attr.symbolize_keys
      
    options = {}
    
    [:limit, :offset].each do |symbol|
      if number = attr[symbol]
        if number =~ /^\d{1,4}$/
          options[symbol] = number.to_i
        else
          raise TagError.new("`#{symbol}' attribute of `each' tag must be a positive number between 1 and 4 digits")
        end
      end
    end
    
    by = (attr[:by] || 'position').strip
    order = (attr[:order] || 'asc').strip
    order_string = ''
    if Audio.column_names.include?(by)
      order_string << by
    else
      raise TagError.new("`by' attribute of `each' tag must be set to a valid field name")
    end
    if order =~ /^(asc|desc)$/i
      order_string << " #{$1.upcase}"
    else
      raise TagError.new(%{`order' attribute of `each' tag must be set to either "asc" or "desc"})
    end
    options[:order] = order_string
    options
  end
  
end