class ThankController < ApplicationController
  WEBHOOK_URL = ENV['SLACK_WEBHOOK_URL']
  CHANNEL = "#プロ研"
  USER_NAME = "玉利 泰人"

  def send(message)
    Slack::Notifier.new(WEBHOOK_URL, channel: CHANNEL, username: USER_NAME).ping('message')
  end
end
