require 'sinatra/base'

module Quest
  class API < Sinatra::Base

    get '/status' do
      MESSENGER.raw_status
    end

    get '/quests' do
      MESSENGER.quests.to_json
    end

    post '/begin/:quest' do
      MESSENGER.change_quest(params[:quest])
    end
  end

end
