require 'rails_helper'

describe "GET" 'index' do

    it "should have a search bar" do
        visit root_path
        expect(page).to have_selector('#search-bar')
    end

    it 'has a date tree full of decades' do
        visit root_path
        expect(page).to have_selector('.decade_link')
    end

    it 'has a date tree that unfolds decades to reveal years' do
        visit root_path
        click_link '1950s'
        expect(page).to have_selector('.year_link')
    end

    it 'has a date tree that unfolds decades to reveal years and years to reveal issues' do
        visit root_path
        click_link '1950s'
        click_link '1950'
        expect(page).to have_selector('.issue_link')
    end

    it 'clicking an issue loads a page containing that issue' do
        visit root_path
        click_link '1950s'
        click_link '1950'
        click_link 'Vol. 1, No. 1, Spring'
        expect(find('#issue_panel h3')).to have_content('Vol. 1, No. 1, Spring')
    end
    
    it 'when clicking on an issue from the date tree, the tree should remain open.' do
        visit root_path
        click_link '1950s'
        click_link '1950'
        click_link 'Vol. 1, No. 1, Spring'
        expect(first('.issue_link')).to have_content('Vol. 1, No. 1, Spring')
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

    it "should get search results from the API" do
        visit root_path
        within '#search-bar' do
            fill_in 'search', :with => 'Pound'
        end
        choose 'choice_author'
        click_button 'Search'
        expect(find('#issue_panel')).to have_content('Pound')
        expect(find('#issue_panel')).to have_selector('.metadata')
    end
end

# TODO some of these tests are specific to the dataset for the shenandoah project. So you'll need to abstract them for more general use in other contexts.

    
    
    