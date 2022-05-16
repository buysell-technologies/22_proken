class ApplicationController < ActionController::Base
  def hello
    client = Slack::Web::Client.new
    client.chat_postMessage(
      channel: '#プロ研',
      text: 'こんにちは'
    )
  end
end
