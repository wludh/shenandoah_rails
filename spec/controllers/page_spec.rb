require 'rails_helper'

describe PagesController do

    describe "GET 'index'" do
        it 'returns http success header' do
            get :index
            expect(response).to be_success
            expect(response).to have_http_status(200)
        end
        it 'renders the index template' do
            get :index
            expect(response).to render_template("index")
        end        

        it "should connect to the json API" do
            controller.fetch_json('/Decades')
            expect(response).to have_http_status(200)
        end

    end

    describe "GET 'about'" do
        it 'returns http success header' do
            get :about
            expect(response).to be_success
            expect(response).to have_http_status(200)
        end
        it 'renders the about template' do
            get :about
            expect(response).to render_template("about")
        end
    end
end