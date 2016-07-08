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

        # if there are search params, call the search function and ignore the new params.
        if params.key?(:issue_id)
            params.delete(:search)
            # if there is an issue_id, render that single issue
            @issue = single_issue(params[:issue_id])
            @articles = articles_in_issue(params[:issue_id]).paginate(:page => params[:page], :per_page => 10)
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

    def years_for_decade(val)
        years_in_decade(val)
    end

    # queries for the JSON endpoint

    def fetch_json(query)
        # puts(ENDPOINT + query)
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

    # for manipulating json in view

    def generate_title(article)
        if article.key?('Title')
            (article['Title'] + "<br>").html_safe
        end
    end

    def generate_author(article)
        if article.key?('AuthorID') && !article['AuthorID'].empty?
            ("Author: " + single_author(article['AuthorID'][0]) + "<br>").html_safe
        end
    end

    def generate_page_nums(article)
        if (article.key?('EndPage') && article.key?('StartPage')) && article['EndPage'] != 0
            ("pp. " + article['StartPage'].to_s + '-' + article['EndPage'].to_s + "<br>").html_safe
        end
    end

    def generate_genres(article)
        if !article['Genre'].empty?
            ("Genre: " + article['Genre'].to_set.to_a.to_sentence + "<br>").html_safe
        end
    end

    def generate_reviews(article)
        if article.key?(:reviews)
            ("Reviewed Works: " + article[:reviews] + "<br>").html_safe
        end
    end

    def generate_notes(article)
        if article.key?(:comments)
            ("Notes: " + article[:comments]+ "<br>").html_safe
        end
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

    # all the methods for manipulating the json in the view
    helper_method :generate_title
    helper_method :generate_author
    helper_method :generate_page_nums
    helper_method :generate_genres
    helper_method :generate_reviews
    helper_method :generate_notes

    # Todo: edit display
    # TODO: Comments and reviews. where are they showing up in the JSON?
    # TODO: optimize - the call in the metadata to single_author for each article is super slow. That's the main slow down right now.

end