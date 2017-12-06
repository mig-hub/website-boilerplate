# encoding: utf-8
require 'sinatra/base'
require 'slim'
require 'redcarpet'
require 'web_utils'

class Main < Sinatra::Base

  set :root, ::File.expand_path('../..', __FILE__)

  set :static_cache_control, [:public, max_age: 600]

  set(
    :markdown_parser,
    Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(:hard_wrap => true),
      :autolink => true,
      :no_intra_emphasis=>true,
      :space_after_headers => true
    )
  )

  before do
    cache_control :public, :must_revalidate, max_age: 60

    unless request.xhr?
      @meta_title = 'Title'
      @meta_description = "Description"
    end
  end

  get '/' do
    slim :home
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

  end

end

