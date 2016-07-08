class PagesController < ApplicationController
    require 'open-uri'
    require 'date'
    require 'active_support/core_ext/array/conversions.rb'
    
    # the json api endpoint that you'll be calling.

    ENDPOINT = "http://managementtools4.wlu.edu/REST/Shenandoah.svc"


    def show
        render template: 'page/#{params[:page]}'
    end

    def index

        # if there are search params, call the search function.
        if params.key?(:issue_id)
            params.delete(:search)
            # if there is an issue_id, render that single issue
            @issue = single_issue(params[:issue_id])
            @articles = articles_in_issue(params[:issue_id])
        elsif params.key?(:search)
            # if there is a search param, search
            api_results = search
            @articles = api_results.paginate(:page => params[:page], :per_page => 10)
            @results_length = api_results.length
            # @num_results = @articles.length
        else
            "NIGHTMARE"
        end

        # generate the date tree
        # generate the decade tree
        @decades = decades

        if params.key?(:decade)
            # if we have a decade in storage, search for the number of years
            @years = years_for_decade(params[:decade])
        end
        if params.key?(:year)
            @issues = all_issues_in_a_year(params[:year])
        end
        #TODO note: will just reset if you choose year

        render template: 'pages/index'

    end

    def about
        render template: 'pages/about'
    end

    def search
        # right now this will just get the json you need
        if params.key?(:search) and params[:choice] == 'author'
            return author_search(params[:search])
        elsif params.key?(:search) and params[:choice] == 'keyword'
            return keyword_search(params[:search])
        else
            raise "something went wrong with the search" 
        end
    end


    def generate_dates
        # this is the slow part. it's hitting every object in the database to pull all the dates.

        # to get from the api

        # years = []
        @decades = decades()
        # for decade in decades
        #     for year in years_in_decade(decade)
        #         years << all_issues_in_a_year(year)
        #     end
        # end

        # to get from local file
        years = File.open('./lib/assets/dates.txt').readline
        years

    end

    def years_for_decade(val)
        data = years_in_decade(val)
        data
    end

    # queries for the JSON endpoint

    def fetch_json(query)
        puts(ENDPOINT + query)
        # Rails.cache.fetch([ENDPOINT, query], :expires => 1.hour) do
            JSON.load(open(ENDPOINT + query))
        # end
    end

    def all_issues_in_a_year(year)
        fetch_json("/Issues?year=#{year}")
    end

    def single_author(author_id)
        result = fetch_json("/Authors/#{author_id}")
        "#{result['FirstName']} #{result['MiddleName']} #{result['LastName']}"
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
        fetch_json("/Articles?Author=#{author}")
    end

    def keyword_search(search)
        fetch_json("/Articles?Text=#{search}")
    end

    helper_method :generate_dates
    helper_method :parse_json
    helper_method :fetch_json
    helper_method :search
    helper_method :years_for_decade
    
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
    # TODO: Comments and reviews. where are they showing up in the JSON?
    # TODO: optimize - the call in the metadata to single_author for each article is super slow. That's the main slow down right now.
    # TODO: work on caching re: the date tree
    # TODO: you are working on the date tree.
end