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
end