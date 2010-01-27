class AudioPlayerExtensionError < StandardError; end

class AudioPlayerExtension < Radiant::Extension
  version "0.1"
  description "Easily upload mp3 files, and embed them on your site with a Flash audio player."
  url "http://github.com/nelstrom/radiant-audio_player-extension/tree/master"

  define_routes do |map|
    
    map.with_options(:controller => 'audio') do |playlist|
      playlist.playlist_index     'songs/playlist.xml',     :action => 'index'
    end
    
    map.with_options(:controller => 'admin/audio') do |audio|
      audio.audio_index           'admin/audio',              :action => 'index'
      audio.audio_new             'admin/audio/new',          :action => 'new'
      audio.audio_new             'admin/audio/create',       :action => 'create'
      audio.audio_edit            'admin/audio/edit/:id',     :action => 'edit'
      audio.audio_remove          'admin/audio/remove/:id',   :action => 'remove'
      audio.audio_new             'admin/audio/destroy/:id',  :action => 'destroy'
      audio.audio_reorder         'admin/audio/reorder',      :action => 'reorder'
      audio.audio_update_order    'admin/audio/update_order', :action => 'update_order'
      audio.audio_update          'admin/audio/update/:id',   :action => 'update'
    end
    
    map.with_options(:controller => 'admin/audio_player_config') do |config|
      config.audio_player_config_index  'admin/audio_player_config',            :action => 'index'
      config.audio_player_config_new    'admin/audio_player_config/new',        :action => 'new'
      config.audio_player_config_new    'admin/audio_player_config/create',     :action => 'create'
      config.audio_player_config_edit   'admin/audio_player_config/edit/:id',   :action => 'edit'
      config.audio_player_config_remove 'admin/audio_player_config/remove/:id', :action => 'remove'
    end
  end

  def activate
    ActiveSupport::Inflector.inflections do |inflect|
      inflect.uncountable "audio" # cause 'audios' just sounds wrong!
    end
    admin.tabs.add "Audio", "/admin/audio", :after => "Layouts", :visibility => [:all]
    Page.send :include, AudioTags
    AudioPage
  end

end