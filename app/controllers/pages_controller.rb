class PagesController < ApplicationController
    # check a user's browser before you do anything.
    before_action :detect_browser

    public
    # import libraries to extend some basic functions: parsing json, parsing dates, and paginating things not associated with a model.
    require 'open-uri'
    require 'date'
    require 'active_support/core_ext/array/conversions.rb'
    
    # the json api endpoint that you'll be calling.
    ENDPOINT = "http://managementtools4.wlu.edu/REST/Shenandoah.svc"

    def show
        render template: 'page/#{params[:page]}'
    end

    def index

        # if there is an issue_id, the user is browsing. Call
        if params.key?(:issue_id)
            # if there is an issue_id, render that single issue and act like there aren't search params. we default to browse if that is being used.
            params.delete(:search)
            # get issue information based on the issue_id
            @issue = single_issue(params[:issue_id])
            # load the articles for that issue.
            @articles = articles_in_issue(params[:issue_id]).paginate(:page => params[:page], :per_page => 10)
        elsif params.key?(:search)
            params.delete(:issue_id)
            # if there is a search param, search for them using the search method defined below.
            api_results = search
            # paginate those results using the default paramaters provided here
            @articles = api_results.paginate(:page => params[:page], :per_page => 10)
            # store the total number of search results.
            @results_length = api_results.length
        else
            # default to a keyword search for 'Shenandoah'
            params[:issue_id] = '1524'
            # then paginate and store the length as above.
            @issue = single_issue(params[:issue_id])
            # load the articles for that issue.
            @articles = articles_in_issue(params[:issue_id]).paginate(:page => params[:page], :per_page => 10)
        end

        # generate the decade tree by calling the decades method defined below.
        @decades = decades

        if params.key?(:decade)
            # if we have a decade in storage, search for the number of years for that decade.
            @years = years_in_decade(params[:decade])
        end
        if params.key?(:year)
            # if we have a year in storage, search for the number of issues in that year.
            @issues = all_issues_in_a_year(params[:year])
        end

        respond_to do |format|
            # finally, now that you have all the data you need, render the view. phone's get a special view that excludes the browse tree. everyone else gets a search bar and browse tree.
            format.html do |variant|
                variant.phone { phone_setup }
                variant.none { render template: 'pages/index' }
            end
        end

    end

    def about
        # render the about page.
        render template: 'pages/about'
    end

    def search
        # get the json from the API endpoint
        if params.key?(:search) and params[:choice] == 'author'
            return author_search(params[:search])
        elsif params.key?(:search) and params[:choice] == 'keyword'
            return keyword_search(params[:search])
        else
            # the error message to show the user if something wonky happened
            raise "something went wrong with the search" 
        end
    end

    def phone_setup
        # called to populate the browse tree for mobile visitors.
        @dropdown_issues = all_articles
        @issue_array = []
        for issue in @dropdown_issues
            @issue_array << ["Vol. #{issue['Volume'].to_s}, No. #{issue['IssueLabel']}, #{issue['Season']} #{issue['Year'].to_s}", issue['ID']]
        end
    end

    # queries for the JSON endpoint

    def fetch_json(query)
        # query the JSON API using the queries provided below
        JSON.load(open(ENDPOINT + query))
    end

    def all_issues_in_a_year(year)
        # get all issues in a year
        fetch_json("/Issues?year=#{year}")
    end

    def single_author(author_id)
        # get a single author and format the name accordingly
        result = fetch_json("/Authors/#{author_id}")
        "#{result['FirstName']} #{result['MiddleName']} #{result['LastName']}"
    end

    def articles_in_issue(issue_id)
        # get all the articles for a single issue
        fetch_json("/Issues/#{issue_id}/Articles")
    end

    def author_for_single_article(article_id)
        # get the author of a single article
        fetch_json("/Articles/#{article_id}/Authors")
    end

    def decades
        # get all the decades that the journal has been running
        fetch_json("/Decades")
    end

    def single_article(article_id)
        # get a single article's data
        fetch_json("/Articles/#{article_id}")
    end

    def years_in_decade(decade)
        # get all the years in each decade tha the journal published something
        fetch_json("/Years/#{decade}")
    end

    def all_articles
        # get all the issues and their associated articles
        fetch_json("/Issues")
    end

    def single_issue(issue_id)
        # get a single issue
        fetch_json("/Issues/#{issue_id}")
    end

    def author_search(author)
        # search for an author
        fetch_json("/Articles?Author=#{author}")
    end

    def keyword_search(search)
        # search for a keyword
        fetch_json("/Articles?Text=#{search}")
    end

    # for manipulating json in view. are called from the view at app/views/layouts/_results.html.erb

    def generate_title(article)
        # check to see if an article has a title. if it does, render the title followed by a line break. Note that all of these functions include a line break.
        if article.key?('Title')
            (article['Title'] + "<br>").html_safe
        end
    end

    def generate_author(article)
        # check to see if an article has an author id associated with it and that it is not an empty field. If it meets both those requirements, query the json api to get the author's information.
        if article.key?('AuthorID') && !article['AuthorID'].empty?
            ("Author: " + single_author(article['AuthorID'][0]) + "<br>").html_safe
        end
    end

    def generate_page_nums(article)
        # check to see if the article has page numbers and to see if they do not end on page 0 (how the database currently identifies internet articles.)
        if (article.key?('EndPage') && article.key?('StartPage')) && article['EndPage'] != 0
            ("pp. " + article['StartPage'].to_s + '-' + article['EndPage'].to_s + "<br>").html_safe
        end
    end

    def generate_genres(article)
        # check to see if an article has genres. If so, take them from json, collapse repeated genres into a set of unique genre keywords, and output it as a sentence - for example '……, and poetry'
        if !article['Genre'].empty?
            ("Genre: " + article['Genre'].to_set.to_a.to_sentence + "<br>").html_safe
        end
    end

    def generate_reviews(article)
        # check to see if an article has genres. If so, output them.
        if article.key?(:reviews)
            ("Reviewed Works: " + article[:reviews] + "<br>").html_safe
        end
    end

    def generate_notes(article)
        # check to see if an article has comments. If so, render them.
        if article.key?(:comments)
            ("Notes: " + article[:comments]+ "<br>").html_safe
        end
    end

    def generate_issue_info(article, first=false)
        # generate the issue header for an article when searching. In the format: Vol. #, No. #, Season Year. with special style if working with the first header.
        if params.key?(:search) && first
            @issue = single_issue(article['IssueID'])
            ("<h3 id='issue_header'> Vol. " + @issue['Volume'].to_s + ", No. " + @issue['Issue'].to_s + ", " + @issue['Season'].to_s + " " + @issue['Year'].to_s + "</h3>").html_safe 
        else
            @issue = single_issue(article['IssueID'])
            ("<h3> Vol. " + @issue['Volume'].to_s + ", No. " + @issue['Issue'].to_s + ", " + @issue['Season'].to_s + " " + @issue['Year'].to_s + "</h3>").html_safe    
        end
    end

private

    def detect_browser
        # a private method that checks which browser a user is using to acces the site. using this, we can then call a special partial for phone users.
        case request.user_agent
            when /iPhone/i
                request.variant = :phone
            when /Android/i && /mobile/i
                request.variant = :phone
            when /Windows Phone/i
                request.variant = :phone
            else
                request.variant = :none
        end
    end

    # all the helper methods that are used to generate the view.
    helper_method :generate_dates
    helper_method :parse_json
    helper_method :fetch_json
    helper_method :search
    
    # all the JSON API methods
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
    helper_method :generate_issue_info

    # TODO: Comments and reviews. where are they showing up in the JSON?

end