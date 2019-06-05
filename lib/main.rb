# encoding: utf-8
require 'sinatra/base'
require 'slim'
require 'redcarpet'
require 'web_utils'

class Main < Sinatra::Base

  MetaImage = Struct.new(:url, :width, :height)

  set :root, ::File.expand_path('../..', __FILE__)

  set :static_cache_control, [:public, max_age: 600]

  set(
    :markdown_parser,
    Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(:hard_wrap => true, link_attributes: {target: '_blank'}),
      :autolink => true,
      :no_intra_emphasis=>true,
      :space_after_headers => true
    )
  )

  before do
    cache_control :public, :must_revalidate, max_age: 60

    unless request.xhr?
      @meta_site_name = 'Title'
      @meta_title = @meta_site_name.dup
      @meta_description = "Description"
      @meta_image = nil
    end
  end

  get '/' do
    slim :home
  end

  get '/cookie-policy' do
    @meta_title = "Cookie Policy - #{@meta_title}"
    slim :cookie_policy
  end

  get '/sitemap.xml' do
    @domain = 'http://www.example.com'
    content_type 'text/xml'
    slim :sitemap, layout: false
  end

  get '/placeholder/:width-:height-:color.svg' do
    content_type 'image/svg+xml'
    cache_control :public, :must_revalidate, max_age: 3600
    "<svg version='1.1' width='#{params[:width]}' height='#{params[:height]}' xmlns='http://www.w3.org/2000/svg'><rect width='100%' height='100%' fill='##{params[:color]}' /></svg>"
  end

  not_found do
    @msg = 'Not Found'
    slim :error
  end

  error do
    @msg = "Error: #{env['sinatra.error'].message}"
    slim :error
  end

  # For certbot ssl certificate challenge
  get "/.well-known/acme-challenge/:certbot_validation" do
    ENV['CERTBOT_TOKEN']
  end


  helpers do

    include WebUtils

    def mobile?
      request.user_agent =~ /iphone|android|iphone|ipad/i
    end

    def md txt
      settings.markdown_parser.render txt.to_s
    end

    def placeholder width, height=nil, color='f6f6f6'
      height ||= width
      "/placeholder/#{width}-#{height}-#{color.sub(/^#/,'')}.svg"
    end

    def preview?
      ['yes','true'].include?(params[:_preview])
    end

    def not_live_yet
      pass if settings.production? and not preview?
    end

    def pass_unless_published object
      if object.respond_to? :published?
        pass unless object.published? or preview?
      elsif object.respond_to? :published
        pass unless object.published or preview?
      else
        raise "#{object} does not respond to :published? or :published."
      end
    end

    VIMEO_BASE_OPTS = {
      color: 'ffffff',
      title: 0,
      byline: 0,
      portrait: 0,
      autopause: 0,
      playbar: 0,
    }
    VIMEO_LOOP_OPTS = {
      autoplay: 1,
      muted: 1,
      loop: 1,
      background: 1,
    }
    YOUTUBE_BASE_OPTS = {
      rel: 0,
      controls: 0,
      showinfo: 0,
      autopause: 0,
      autohide: 1,
      modestbranding: 1,
    }
    YOUTUBE_LOOP_OPTS = {
      autoplay: 1,
      loop: 1,
      mute: 1,
      fs: 0,
    }
    def video_src video_id, options={}
      player = options.delete(:player) || guess_video_player(video_id)
      loop_mode = options.delete(:loop_mode) || false
      if player == :youtube
        base_url = 'https://www.youtube.com/embed/'
        player_options = YOUTUBE_BASE_OPTS.dup.merge(playlist: video_id)
        player_options.merge!(YOUTUBE_LOOP_OPTS) if loop_mode
      else
        base_url = 'https://player.vimeo.com/video/'
        player_options = VIMEO_BASE_OPTS.dup
        player_options.merge!(VIMEO_LOOP_OPTS) if loop_mode
      end
      player_options.merge!(options)
      player_options_string = player_options.map do |k,v|
        "#{k}=#{v}"
      end.join('&amp;')
      "#{base_url}#{video_id}?#{player_options_string}"
    end
    def guess_video_player video_id
      video_id =~ /^\d+$/ ? :vimeo : :youtube
    end

  end

end

