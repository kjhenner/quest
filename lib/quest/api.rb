require 'sinatra/base'

module Quest

  class API < Sinatra::Base

    get '/status' do
      settings.messenger.quest_status[settings.mesisenger.active_quest].to_json
    end

    get '/active_quest' do
      settings.messenger.active_quest
    end

    get '/quests' do
      settings.messenger.quests.to_json
    end

    post '/begin/:quest' do
      settings.messenger.begin_quest(params[:quest])
    end
  end

end
