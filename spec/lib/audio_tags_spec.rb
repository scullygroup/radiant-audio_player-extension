require File.dirname(__FILE__) + '/../spec_helper'

describe "Audio tags" do
  dataset :audio_page_dataset
  
  before(:each) do
    @page = pages(:home)
    @audio_tracks = Audio.find(:all, :order => 'position ASC')
  end
  
  it "should render contents of r:tracks" do
    @page.should render('<r:tracks>Whatever</r:tracks>').as('Whatever')
  end
  
  # finding a particular track
  
  it "should find an audio track when given its id" do
    target = Audio.find(:first)
    @page.should render(%Q{<r:track id="#{target.id}"><r:title/></r:track>}).
      as(target.title)
  end
  
  it "should find an audio track when given an existing title" do
    target = Audio.find(:first)
    @page.should render(%Q{<r:track title="#{target.title}"><r:title/></r:track>}).
      as(target.title)
  end
  
  it "should show nothing when given a non-existing title" do
    target = Audio.find(:first)
    @page.should render(%Q{<r:track title="#{target.title}... not!"><r:title/></r:track>}).
      as('')
  end
  
  it "should show nothing when given an id for a non-existent audio track" do
    # assuming that sample records are created with large value ids, 
    # a low value id should match nothing.
    @page.should render(%Q{<r:track id="42"><r:title/></r:track>}).
      as('')
  end
  
  # iterating through audio tracks
  
  it "should render contents of r:tracks:each for each audio track" do
    @page.should render('<r:tracks:each>a </r:tracks:each>').as('a a a ')
  end
  
  # ordering of audio tracks
  
  it "should fetch audio tracks ordered by position ascending (default)" do
    @page.should render('<r:tracks:each><r:title/> </r:tracks:each>').
      as(@audio_tracks.map{ |track| "#{track.title} " }.join)
  end
  
  it "should fetch audio tracks ordered by position descending" do
    @page.should render('<r:tracks:each order="desc"><r:title/> </r:tracks:each>').
      as(@audio_tracks.reverse.map{ |track| "#{track.title} " }.join)
  end
  
  it "should fetch audio tracks ordered by title ascending" do
    @page.should render('<r:tracks:each by="title"><r:title/> </r:tracks:each>').
      as("Debut Mostly harmless Richly described ")
  end
  
  it "should fetch audio tracks ordered by title descending" do
    @page.should render('<r:tracks:each by="title" order="desc"><r:title/> </r:tracks:each>').
      as("Richly described Mostly harmless Debut ")
  end
  
  it "should fetch audio tracks ordered by created_at ascending" do
    @page.should render('<r:tracks:each by="created_at"><r:title/> </r:tracks:each>').
      as("Richly described Mostly harmless Debut ")
  end
  
  it "should fetch audio tracks ordered by created_at descending" do
    @page.should render('<r:tracks:each by="created_at" order="desc"><r:title/> </r:tracks:each>').
      as("Debut Mostly harmless Richly described ")
  end
  
  # limit and offset when fetching a collection
  
  it "should only fetch the first 2 results" do
    @page.should render('<r:tracks:each limit="2"><r:title/> </r:tracks:each>').
      as(@audio_tracks[0..1].map{ |track| "#{track.title} " }.join)
  end
  it "should skip the first track with offset of 1" do
    @page.should render('<r:tracks:each limit="2" offset="1"><r:title/> </r:tracks:each>').
      as(@audio_tracks[1..2].map{ |track| "#{track.title} " }.join)
  end
  
  
  # Fetching attributes of each track whilst iterating through them
  
  it "should render description of each audio track with r:tracks:each:description" do
    @page.should render('<r:tracks:each><r:description/></r:tracks:each>').
      as(@audio_tracks.map{ |track| "#{track.description_with_filter}" }.join)
  end
  
  it "should find the url for audio tracks with r:link" do
    @page.should render('<r:tracks:each><r:link/></r:tracks:each>').
      as(@audio_tracks.map{ |track| "<a href=\"/audio/#{track.to_param}\" title=\"#{track.title}\">#{track.title}</a>" }.join)
  end
  
  it "should output code for embedded player with r:track:player" do
    @page.should render('<r:tracks:each><r:player/></r:tracks:each>').
      as(@audio_tracks.map{ |track| embed_helper(track) }.join)
  end
  
  private
  
  def embed_helper(audio_track)
    %Q{<object type=\"application/x-shockwave-flash\" data=\"/flash/audio_player/player.swf\" id=\"audioplayer#{audio_track.id}\" height=\"24\" width=\"290\">
<param name=\"movie\" value=\"/flash/audio_player/player.swf\">
<param name=\"FlashVars\" value=\"autostart=no&amp;loop=no&amp;playerID=#{audio_track.id}&amp;soundFile=/audio/#{audio_track.id}/#{audio_track.track_file_name}\">
<param name=\"quality\" value=\"high\">
<param name=\"menu\" value=\"false\">
<param name=\"wmode\" value=\"transparent\">
</object>}
  end
  
end