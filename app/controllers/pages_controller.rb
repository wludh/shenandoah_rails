class PagesController < ApplicationController

    def show
        render template: 'page/#{params[:page]}'
    end

    def index
        if params[:search] != nil
            query = params[:search].html_safe
            @choice = params[:choice]
            puts(query) 
        end

        # if @articles
        @articles = [{title: 'Test title', pages: '6-11', author: 'An author test', genre: 'Romance', reviews: 'This is a thing I reviewed', comments: 'A test note', volume: '3', issue: '4', date: 'Spring 1954'}, {title: 'Test pages', pages: '-', author: 'An author test', genre: 'Romance', reviews: 'This is a thing I reviewed', volume: '3', issue: '4', date: 'Spring 1954'}]
        5.times do
            @articles += @articles
        end
        # end    
        render template: 'pages/index'
    end

    def about
        render template: 'pages/about'
    end

    def search
        if params[:search] != nil
            @my_variable = 'a thing goes here' 
            query = params[:search].html_safe
            puts(query) 
        end    
        render template: 'pages/index'
    end

    def parse_json
        """takes the json API and parses it"""
    end

    def parse_metadata
        """takes the json API and produces articles from it""" 
        @articles.each do |article|

        end   
    end

    # helper_method parse_json
    # helper_method parse_metadata
    # helper_method search

    # TODO: query JSON API - this will parse json from a url - http://stackoverflow.com/questions/18581792/ruby-on-rails-and-json-parser-from-url
    # TODO: load JSON - http://ruby-doc.org/stdlib-2.2.3/libdoc/json/rdoc/JSON.html is the one to parse json.
    # generate models from json.
    # TODO: search - https://github.com/scholarslab/prism/commit/05405455b7bf9407fdefa5e63de6c6f78d2ef1ee could be a place to start.
    # Todo: edit display
    # Todo: date tree thing
end