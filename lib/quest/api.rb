require 'sinatra/base'

module Quest
  class API < Sinatra::Base

    get '/status' do
      settings.messenger.quest_status[settings.messenger.active_quest]
    end

    get '/quests' do
      settings.messenger.quests.to_json
    end

    post '/begin/:quest' do
      settings.messenger.begin_quest([:quest])
    end
  end

end
