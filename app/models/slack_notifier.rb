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
    payload = {
      fallback: "send thanks",
      text: message
    }
    client.post text: "#{sender}さんが#{recipient}さんに「#{value}」しました", attachments: [payload]
  end
end
