class PagesController < ApplicationController
    require 'open-uri'
    require 'date'
    
    # the json api endpoint that you'll be calling.
    ENDPOINT = "http://managementtools4.wlu.edu/REST/Shenandoah.svc"

    def show
        render template: 'page/#{params[:page]}'
    end

    def index
        # if there are search paramters, call the search function.
        @articles = search if params.key?(:search)
        
        # generate the date tree
        @dates = generate_dates
        render template: 'pages/index'
    end

    def about
        render template: 'pages/about'
    end

    def search
        # right now this will just get the json you need
        if params.key?(:search) and params[:choice] == 'author'
            return parse_json(author_search(params[:search]))
        elsif params.key?(:search) and params[:choice] == 'keyword'
            return parse_json(keyword_search(params[:search]))
        else
            raise "something went wrong with the search" 
        end
    end

    def parse_json(some_json)
        # takes the json API and produces articles from it 
        # should eventually parse some json. but for now it is not.
        @articles = [{title: 'Test title', pages: '6-11', author: 'An author test', genre: 'Romance', reviews: 'This is a thing I reviewed', comments: 'A test note', volume: '3', issue: '4', date: 'Spring 1954'}, {title: 'Test pages', author: 'An author test', genre: 'Romance', reviews: 'This is a thing I reviewed', volume: '3', issue: '4', date: 'Spring 1954'}]
        5.times do
            @articles += @articles
        end
        return @articles
    end

    def generate_dates
        # this is the slow part. it's hitting every object in the database to pull all the dates.
        years = []
        issue_dates = []
        decades = decades()
        for decade in decades
            for year in years_in_decade(decade)
                years << all_issues_in_a_year(year)
            end
        end
        years = File.open('./lib/assets/dates.txt').readline
        # years
        # date = Date.new(1950, 1, 1)
        # counter = 1 
        # result = 0
        # @date_array = []
        # until result == 2015 do
        #     result = date.year + counter
        #     @date_array << (date.year + counter)
        #     counter += 1
        # end
        # return @date_array
    end

    # queries for the JSON endpoint

    def fetch_json(query)
        puts(ENDPOINT + query)
        JSON.load(open(ENDPOINT + query))
    end

    def all_issues_in_a_year(year)
        puts "********"
        puts(fetch_json("/Issues?year=#{year}"))
        fetch_json("/Issues?year=#{year}")
    end

    def single_author(author_id)
        fetch_json("/Authors/#{author_id}")
    end

    def articles_in_issue(issue_id)
        fetch_json("/Issues/#{issue_id}/Articles")
    end

    def author_for_single_article(article_id)
        fetch_json("/Articles/#{article_id}/Authors")
    end

    def decades
        fetch_json("/Decades")
    end

    def single_article(article_id)
        fetch_json("/Articles/#{article_id}")
    end

    def years_in_decade(decade)
        fetch_json("/Years/#{decade}")
    end

    def all_articles
        fetch_json("/Issues")
    end

    def single_issue(issue_id)
        fetch_json("/Issues/#{issue_id}")
    end

    def author_search(author)
        # you'll need to do a whole lot more integrating the other methods to walk down the data tree once jeff gets back to you.
        fetch_json("/Articles/Author=#{author}")
    end

    def keyword_search(search)
        # you'll need to do a whole lot more integrating the other methods to walk down the data tree once jeff gets back to you.

        fetch_json("/Articles/Text=#{search}")
    end

    helper_method :generate_dates
    helper_method :parse_json
    helper_method :fetch_json
    helper_method :search
    
    # all the JSON API methods
    helper_method :all_articles
    helper_method :all_issues_in_a_year
    helper_method :single_author
    helper_method :articles_in_issue
    helper_method :author_for_single_article
    helper_method :decades
    helper_method :single_article
    helper_method :years_in_decade
    helper_method :all_articles
    helper_method :single_issue
    helper_method :author_search
    helper_method :keyword_search

    # TODO: query JSON API - this will parse json from a url - http://stackoverflow.com/questions/18581792/ruby-on-rails-and-json-parser-from-url
    # TODO: load JSON - http://ruby-doc.org/stdlib-2.2.3/libdoc/json/rdoc/JSON.html is the one to parse json.
    # generate models from json.
    # Todo: edit display
    # Todo: date tree thing
end