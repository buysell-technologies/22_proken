class SlackNotifier
  attr_reader :client

  # 環境SLACK_WEBHOOK_URLにwebhook urlを格納
  WEBHOOK_URL = ENV['SLACK_WEBHOOK_URL']
  CHANNEL = "#プロ研"
  USER_NAME = "testapp"

  def initialize
    @client = Slack::Notifier.new(WEBHOOK_URL, channel: CHANNEL, username: USER_NAME)
  end

  def send(sender, recipient, value, message)
    client.post blocks: [
      {
        "type": "section",
        "text": {
          "type": "plain_text",
          "text": "#{sender}さんが#{recipient}さんに「#{value}」しました",
          "emoji": true
        }
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "> #{message}"
        }
      },
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": "#{recipient}さんに「#{value}」を送りますか",
              "emoji": true
            },
            "value": "click_me_123",
            "action_id": "actionId-0"
          }
        ]
      }
    ]
  end

  def hoge()
    client.post blocks: [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": "感謝を送ろう",
          "emoji": true
        }
      },
      {
        "type": "divider"
      },
      {
        "type": "input",
        "element": {
          "type": "multi_users_select",
          "placeholder": {
            "type": "plain_text",
            "text": "選択",
            "emoji": true
          },
          "action_id": "multi_users_select-action"
        },
        "label": {
          "type": "plain_text",
          "text": "メンバーの選択",
          "emoji": true
        }
      },
      {
        "type": "input",
        "element": {
          "type": "multi_users_select",
          "placeholder": {
            "type": "plain_text",
            "text": "選択",
            "emoji": true
          },
          "action_id": "multi_users_select-action"
        },
        "label": {
          "type": "plain_text",
          "text": "バリューの選択",
          "emoji": true
        }
      },
      {
        "type": "input",
        "element": {
          "type": "plain_text_input",
          "multiline": true,
          "action_id": "plain_text_input-action"
        },
        "label": {
          "type": "plain_text",
          "text": "感謝する内容",
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
              "emoji": true,
              "text": "送信"
            },
            "style": "primary",
            "value": "click_me_123",
            "action_id": "actionId-0"
          }
        ]
      }
    ]
  end
end
