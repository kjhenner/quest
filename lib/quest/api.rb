require 'sinatra/base'

module Quest

  class API < Sinatra::Base

    # Set defaults
    before { content_type 'application/json' }
    not_found { JSON.dump("error" => "Not Found") }

    helpers do
      def messenger
        settings.messenger
      end
      def quest_status
        settings.messenger.quest_status
      end
      def active_quest
        settings.messenger.active_quest
      end
      def active_quest_status
        settings.messenger.quest_status[settings.messenger.active_quest]
      end
    end

    get '/status' do
      active_quest_status.to_json
    end

    get '/status/examples' do
      active_quest_status[:examples].to_json
    end

    get '/status/examples/:number' do
      active_quest_status[:examples][params[:number].to_i - 1].to_json
    end

    get '/status/examples/count' do
      active_quest_status[:examples].size.to_json
    end

    get '/status/examples/:number/description' do
      active_quest_status[:examples][params[:number].to_i - 1][:description].to_json
    end

    get '/status/examples/:number/file_path' do
      active_quest_status[:examples][params[:number].to_i - 1][:file_path].to_json
    end

    get '/status/examples/:number/status' do
      active_quest_status[:examples][params[:number].to_i - 1][:status].to_json
    end

    get '/status/examples/:number/run_time' do
      active_quest_status[:examples][params[:number].to_i - 1][:run_time].to_json
    end

    get '/parsed_status' do
      output = {
        "active_quest" => active_quest
      }
      active_quest_status[:examples].each_with_index do |example, index|
        task_number = "Task #{(index + 1).to_s}"
        output[task_number] = example
      end
      output.to_json
    end

    get '/status/summary' do
      active_quest_status[:summary].to_json
    end

    get '/status/summary/failure_count' do
      active_quest_status[:summary][:failure_count].to_json
    end

    get '/active_quest' do
      active_quest.to_json
    end

    get '/quests' do
      messenger.quests.to_json
    end

    post '/begin/:quest' do
      messenger.begin_quest(params[:quest])
    end
  end

end
