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
    end
  end

  def respond
    if params[:event][:type] == 'app_home_opened'
      user_uid = params[:event][:user]
      views_publish(user_uid)
    elsif params[:event][:type] == 'message' && params[:event][:thread_ts].present? && params[:event][:bot_id].nil? && User.find_by(token: params[:event][:client_msg_id]).nil?
      reply_notion
    end
  end

  def views_publish(user_uid)
    client = Slack::Web::Client.new

    client.views_publish(
      token: ENV['BOT_USER_ACCESS_TOKEN'],
      user_id: "#{user_uid}",
      view: '{"type":"home","blocks":[{"type":"input","element":{"type":"plain_text_input","multiline":true,"action_id":"plain_text_input-action"},"label":{"type":"plain_text","text":"疑問を投稿しよう","emoji":true}},{"type":"actions","elements":[{"type":"button","text":{"type":"plain_text","text":"投稿する","emoji":true},"style":"primary","value":"send_question","action_id":"send-question"}]}]}'
    )
  end

  def action
    @params = JSON.parse(params[:payload])
    if @params['type'] == "view_submission"
      reply_message_block_id = @params['view']['blocks'][0]['block_id']
      reply_message = @params['view']['state']['values'][reply_message_block_id]['plain_text_input-action']['value']
      view_title = @params['view']['blocks'][0]['label']['text']

      case view_title
      when "返信しよう"
        pp '------------------params--------------'
        pp @params
        thread_ts = @params['view']['private_metadata']
        thread = SlackNotifier.new.get_thread(thread_ts)
        thread_first_ts = thread[:messages].first[:ts]
        thread_first_message = thread[:messages][0][:blocks][0][:text][:text]
        view_id = @params['view']['id']

        SlackNotifier.new.reply(
          message: reply_message,
          thread_ts: thread_ts
        )
        SlackNotifier.new.update_modal_view(
          title: view_title,
          view_id: view_id
        )
      when "感謝を送ろう"
        c = Slack::Web::Client.new

        thread_ts = JSON.parse(@params['view']['private_metadata'])['thread_id']
        thread = SlackNotifier.new.get_thread(thread_ts)
        thread_first_ts = thread[:messages].first[:ts]
        thread_first_message = thread[:messages][0][:blocks][0][:text][:text]

        sender_id = JSON.parse(@params['view']['private_metadata'])['sender_id']
        sender = c.users_info(user: sender_id)['user']['real_name']

        SlackNotifier.new.reply(
          message: reply_message,
          thread_ts: thread_ts
        )

        SlackNotifier.new.update_message_done(
          message: thread_first_message,
          ts: thread_first_ts,
          solver: sender
        )

        @thanks_user = Thank.find-by(user_id: sender_id)
        if thanks_user.nil?
          Thank.create(user_id: sender_id, count: 1)
        else
          @thanks_user.update(count: @thanks_user.count + 1)
        end
      end
    end

    action_id = @params['actions'][0]['action_id']

    case action_id
    when 'send-question'

      message_block_id = @params['view']['blocks'][0]['block_id']
      user = @params['user']['id']
      message = @params['view']['state']['values'][message_block_id]['plain_text_input-action']['value']

      SlackNotifier.new.send_question(
        message: message,
        user: user
      )
    when 'open-reply-modal'
      trigger_id = @params['trigger_id']
      thread_ts = @params['message']['metadata']['event_payload']['title']
      thread = SlackNotifier.new.get_thread(thread_ts)
      thread_first_ts = thread[:messages].first[:ts]
      SlackNotifier.new.open_reply_modal(
        trigger_id: trigger_id,
        private_metadata: thread_first_ts
      )
    when 'open-done-modal'
      trigger_id = @params['trigger_id']
      thread_ts = @params['message']['metadata']['event_payload']['title']
      thread = SlackNotifier.new.get_thread(thread_ts)
      thread_first_ts = thread[:messages].first[:ts]
      thread_first_message = thread[:messages][0][:blocks][0][:text][:text]
      sender_id = @params['message']['metadata']['event_payload']['id']
      SlackNotifier.new.open_done_modal(
        trigger_id: trigger_id,
        private_metadata: thread_first_ts,
        sender_id: sender_id
      )
    end
  end


  def reply_notion
    client = Slack::Web::Client.new

    sender_id = params[:event][:user]
    pp "paramas"
    pp params

    pp "sender_id"
    pp sender_id

    thread_ts = params[:event][:thread_ts]
    pp "thread_ts"
    pp thread_ts
    getter_id = User.find_by(thread_id: thread_ts).user_id
    thread_first_message = User.find_by(thread_id: thread_ts).message
    pp "getter_id"
    pp getter_id
    thread_last_message = params[:event][:blocks][0][:elements][0][:elements][0][:text]
    token = params[:event][:client_msg_id]
    pp "dm開始"
    SlackNotifier.new.send_dm(
      message: thread_last_message,
      user_id: getter_id,
      thread_first_ts: thread_ts,
      sender_id: sender_id
    )

    pp "dm終わり"
    User.create(user_id: getter_id, thread_id: thread_ts, message: thread_last_message, token: token)
    # 親スレッドのステータスを「解答中」に更新
    SlackNotifier.new.update_message_process(
      message: thread_first_message,
      ts: thread_ts
      )
  end


  def post_lgtm
    if params["event"]["reaction"] == "grinning"
      sender_id= params["event"]["user"]
      # geter_id= params["event"]["type"]["item_user"]
      client = Slack::Web::Client.new
      SlackNotifier.new.post_lgtm(sender_id)
    end
  end
end
