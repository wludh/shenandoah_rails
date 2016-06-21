class PagesController < ApplicationController

    def show
        render template: 'page/#{params[:page]}'
    end

    def index
        render template: 'pages/index'
    end

    def about
        render template: 'pages/about'
    end

    # TODO: query JSON API - this will parse json from a url - http://stackoverflow.com/questions/18581792/ruby-on-rails-and-json-parser-from-url
    # TODO: load JSON - http://ruby-doc.org/stdlib-2.2.3/libdoc/json/rdoc/JSON.html is the one to parse json.
    # generate models for the objects.
    # generate models from json.
    # TODO: search - https://github.com/scholarslab/prism/commit/05405455b7bf9407fdefa5e63de6c6f78d2ef1ee could be a place to start.
    # Todo: display
    # Todo: date tree thing
end