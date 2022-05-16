class ThankController < ApplicationController
  WEBHOOK_URL = ENV['SLACK_WEBHOOK_URL']
  CHANNEL = "#プロ研"
  USER_NAME = "玉利 泰人"

  def send(message)
    Slack::Notifier.new(WEBHOOK_URL, channel: CHANNEL, username: USER_NAME).ping('message')
  end

  def respond
    if params[:event][:type] == 'app_home_opened'
      views_publish
    elsif params[:event][:type] == 'message' && params[:event][:text].present?
      p "ここは使い方でよさそう"
    end
  end

  def views_publish
    team = Team.find_by(workspace_id: params[:team_id])
    user = User.find_by(uid: params[:event][:user])
    return if team.nil? || user.nil? || team.workspace_id != user.team.workspace_id

    access_token = set_access_token(user.authentication.access_token)
    publish_to_home_tab(team, user, access_token)
  end

  def publish_to_home_tab(team, user, access_token)
    encoded_msg = encoded_home_tab_block_msg(team)
    access_token.post("api/views.publish?user_id=#{user.uid}&view=#{encoded_msg}&pretty=1").parsed
  end

  def encoded_home_tab_block_msg(team)
    channel_id = team.share_channel_id
    channel_name = team.share_channel_name
      msg = "{ここにjson貼ってくれーー}"
    encoded_msg = ERB::Util.url_encode(msg)
    encoded_msg
  end
end
