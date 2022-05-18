class SlackController < ApplicationController
  require 'slack-ruby-block-kit'
  # require 'rails_helper'
  require "erb"
  attr_reader :client

  protect_from_forgery

  def create 
    @header = request.headers
    @body = JSON.parse(request.body.read)
    case @body['type']
    when 'url_verification'
      render json: @body
    when 'event_callback'
      respond
    # when '送信が送られたときのタイプ'
    #   pp "ここでbodyを見て送った人とかの情報とってnoticcerみたいなメッセージ送信のうやつで送ればよさそう"
    end
  end

  def hogehoge
    client = Slack::Web::Client.new
    @params = JSON.parse(params[:payload])

    sender_id = @params['user']['id']
    getter_id = @params['view']['state']['values']['2RI6']['users_select-action']['selected_user']
    sender_user = client.users_info(user: sender_id)['user']['real_name']
    getter_user = client.users_info(user: getter_id)['user']['real_name']
    value = @params['view']['state']['values']['jSQRN']['multi_static_select-action']['selected_option']['text']['text']
    message = @params['view']['state']['values']['IpN']['plain_text_input-action']['value']

    SlackNotifier.new.send(
      sender=sender_user, 
      getter=getter_user, 
      value=value, 
      message=message
    )
  end

  def respond
    if params[:event][:type] == 'app_home_opened'
      views_publish
    elsif params[:event][:type] == 'message' && params[:event][:text].present?
      p "ここは使い方でよさそう"
    end
  end

  def views_publish()
    user_uid = params[:event][:user]
    client = Slack::Web::Client.new
    client.views_publish(
      token=ENV['BOT_USER_ACCESS_TOKEN'],
      user_id=user_uid, 
      view='{"type":"home","blocks":[{"type":"header","text":{"type":"plain_text","text":"感謝を送ろう","emoji":true}},{"type":"divider"},{"type":"input","element":{"type":"users_select","placeholder":{"type":"plain_text","text":"選択","emoji":true},"action_id":"users_select-action"},"label":{"type":"plain_text","text":"メンバーの選択","emoji":true}},{"type":"input","element":{"type":"static_select","placeholder":{"type":"plain_text","text":"選択","emoji":true},"options":[{"text":{"type":"plain_text","text":"さすが","emoji":true},"value":"value-0"},{"text":{"type":"plain_text","text":"すぐ","emoji":true},"value":"value-1"},{"text":{"type":"plain_text","text":"おそれず","emoji":true},"value":"value-2"},{"text":{"type":"plain_text","text":"みずから","emoji":true},"value":"value-3"}],"action_id":"multi_static_select-action"},"label":{"type":"plain_text","text":"バリューの選択","emoji":true}},{"type":"input","element":{"type":"plain_text_input","multiline":true,"action_id":"plain_text_input-action"},"label":{"type":"plain_text","text":"感謝する内容","emoji":true}},{"type":"actions","elements":[{"type":"button","text":{"type":"plain_text","emoji":true,"text":"送信"},"style":"primary","value":"click_me_123","action_id":"actionId-1"}]}]}'
    )
  end
end


