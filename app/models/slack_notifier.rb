class SlackNotifier
  require 'slack-ruby-block-kit'
  attr_reader :client
  require "json"

  # 環境SLACK_WEBHOOK_URLにwebhook urlを格納
  WEBHOOK_URL = ENV['SLACK_WEBHOOK_URL']
  CHANNEL = "#送られる場所"
  USER_NAME = "送られる場所"
  def initialize
    @client = Slack::Notifier.new(WEBHOOK_URL, channel: CHANNEL, username: USER_NAME)
  end

  def send_dm(message: message, user_id: user_id, thread_first_ts: thread_first_ts, sender_id: sender_id)
    pp "-------------res前----------------"
    c = Slack::Web::Client.new
    res = c.conversations_open(users: user_id)
    dm_id = res['channel']['id']
    post_message = c.chat_postMessage(
      channel: dm_id,
      blocks: JSON.dump([
        {
          "type": "section",
          "text": {
            "type": "plain_text",
            "text": "#{message}",
            "emoji": true
          }
        },
        {
          "type": "actions",
          "elements": [
            {
              "type": "button",
              "text": {
                "type": "plain_text",
                "text": "解決した",
                "emoji": true
              },
              "value": "click_me_123",
              "action_id": "open-done-modal"
            },
            {
              "type": "button",
              "text": {
                "type": "plain_text",
                "text": "返信する",
                "emoji": true
              },
              "style": "primary",
              "value": "click_me_123",
              "action_id": "open-reply-modal"
            }
          ]
        }
      ]),
      metadata: JSON.dump({
        "event_type": "dm",
        "event_payload": {
          "id": "#{sender_id}",
          "title": "#{thread_first_ts}"
        }
      })
    )
  end

  def post_lgtm(user_id)
    c = Slack::Web::Client.new
    c.chat_postMessage(
      channel: "C03G8DHTBJS",
      blocks: JSON.dump([
        {
          "type": "section",
          "text": {
            "type": "plain_text",
            "text": "LGTM",
            "emoji": true
          }
        }
      ])
    )
  end

  def send_question(message: message, user: user)
    c = Slack::Web::Client.new
    channel_id = ENV['SLACK_CHANNEL_ID']
    pp user

    post_data = c.chat_postMessage(
      channel: channel_id,
      blocks: JSON.dump([
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": message
          },
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": "未解答",
              "emoji": true
            },
            "style": "danger",
            "value": "click_me_123",
            "action_id": "button-action"
          }
        }
      ])
    )
    pp "-----------------post_data-----------------"
    pp post_data
    User.create(user_id: user, thread_id: post_data['ts'], message: message, token: nil)
  end

  def open_reply_modal(trigger_id: trigger_id, private_metadata: private_metadata)
    # user_id = params[:user][:id]
    # pp JSON.parse(request.body.read)
    client = Slack::Web::Client.new
    client.views_open(
      token: ENV['BOT_USER_ACCESS_TOKEN'],
      trigger_id: trigger_id,
      view: JSON.dump({
        "type": "modal",
        "callback_id": "reply_modal",
        "title": {
          "type": "plain_text",
          "text": "ソルブ",
          "emoji": true
        },
        "submit": {
          "type": "plain_text",
          "text": "送信",
          "emoji": true
        },
        "close": {
          "type": "plain_text",
          "text": "キャンセル",
          "emoji": true
        },
        "blocks": [
          {
            "type": "input",
            "element": {
              "type": "plain_text_input",
              "multiline": true,
              "action_id": "plain_text_input-action"
            },
            "label": {
              "type": "plain_text",
              "text": "返信しよう",
              "emoji": true
            }
          }
        ],
        "private_metadata": private_metadata
      })
    )
    client.views_push(
      token: ENV['BOT_USER_ACCESS_TOKEN'],
      trigger_id: trigger_id,
      view: ""
    )
  end

  def open_done_modal(trigger_id: trigger_id, private_metadata: private_metadata, sender_id: sender_id)
    # user_id = params[:user][:id]
    # pp JSON.parse(request.body.read)
    client = Slack::Web::Client.new

    client.views_open(
      token: ENV['BOT_USER_ACCESS_TOKEN'],
      trigger_id: trigger_id,
      view: JSON.dump({
        "type": "modal",
        "block_id": "replay_block",
        "title": {
          "type": "plain_text",
          "text": "ソルブ",
          "emoji": true
        },
        "submit": {
          "type": "plain_text",
          "text": "投稿する",
          "emoji": true
        },
        "close": {
          "type": "plain_text",
          "text": "キャンセル",
          "emoji": true
        },
        "blocks": [
          {
            "type": "input",
            "element": {
              "type": "plain_text_input",
              "multiline": true,
              "action_id": "plain_text_input-action"
            },
            "label": {
              "type": "plain_text",
              "text": "感謝を送ろう",
              "emoji": true
            }
          }
        ],
        "private_metadata": JSON.dump(
          {
            "thread_id": "#{private_metadata}",
            "sender_id": "#{sender_id}"
          }
        )
      })
    )
  end

  def get_thread(thread_ts)
    c = Slack::Web::Client.new
    c.conversations_replies(
      channel: ENV['SLACK_CHANNEL_ID'],
      ts: thread_ts
    )
  end

  def reply(message: message, thread_ts: thread_ts)
    pp '-------reply--------'
    c = Slack::Web::Client.new

    c.chat_postMessage(
      channel: ENV['SLACK_CHANNEL_ID'],
      text: message,
      thread_ts: thread_ts,
    )
  end

  def update_message_process(message: message, ts: ts)
    c = Slack::Web::Client.new

    res = c.chat_update(
      channel: ENV['SLACK_CHANNEL_ID'],
      ts: ts,
      blocks: JSON.dump([
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": message
          },
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": "解答中",
              "emoji": true
            },
            "style": "primary",
            "value": "click_me_123",
            "action_id": "button-action"
          }
        }
      ])
    )

    pp "---------update res----------------"
    pp res
    pp "-----------------------------------"
  end

  def update_message_done(message: message, ts: ts, solver: solver)
    c = Slack::Web::Client.new

    pp solver

    c.chat_update(
      channel: ENV['SLACK_CHANNEL_ID'],
      ts: ts,
      blocks: JSON.dump([
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": message
          },
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": "#{solver}さんが解決しました",
              "emoji": true
            },
            "value": "click_me_123",
            "action_id": "button-action"
          }
        }
      ])
    )
  end
end
