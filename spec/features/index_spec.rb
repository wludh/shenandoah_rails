require 'rails_helper'

describe "GET" 'index' do

    it "should have a search bar" do
        visit root_path
        expect(page).to have_selector('#search-bar')
    end
    
    it "should store search queries in params" do
        visit root_path
        within '#search-bar' do
            fill_in 'search', :with => 'Test search'
        end
        click_button 'Search'
        parsed_query = CGI::parse(URI.parse(current_url).query)
        expect(parsed_query['search']).to have_content('Test search')
    end

    it "should store in params whether the search is by author" do
        visit root_path
        within '#search-bar' do
            fill_in 'search', :with => 'Test search'
        end
        choose 'choice_author'
        click_button 'Search'
        parsed_query = CGI::parse(URI.parse(current_url).query)
        expect(parsed_query['choice']).to have_content('author')
    end

    it "should store in params whether the search is by keyword" do
        visit root_path
        within '#search-bar' do
            fill_in 'search', :with => 'Test search'
        end
        choose 'choice_keyword'
        click_button 'Search'
        parsed_query = CGI::parse(URI.parse(current_url).query)
        expect(parsed_query['choice']).to have_content('keyword')
    end

    it "should connect to the json API"
    it "should get a response that is JSON from the API"
    it "should parse that JSON"
    it "should take a search and query the API with it"
    it "should get dates from the API"
    it "should get single issues from the API"
    it "should get search results from the API"
end