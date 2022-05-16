require 'slack-ruby-block-kit'
require 'rails_helper'
require "erb"

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
      msg = "{
        "type": "home",
        "blocks": [
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
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "*誰に*\n感謝する人選択しよう"
            },
            "accessory": {
              "type": "static_select",
              "placeholder": {
                "type": "plain_text",
                "emoji": true,
                "text": "例: バイセル 太郎"
              },
              "options": [
                {
                  "text": {
                    "type": "plain_text",
                    "emoji": true,
                    "text": "Aさん"
                  },
                  "value": "value-0"
                },
                {
                  "text": {
                    "type": "plain_text",
                    "emoji": true,
                    "text": "Bさん"
                  },
                  "value": "value-1"
                }
              ]
            }
          },
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "*バリュー*\n感謝する内容に対応するバリューを選択してください"
            },
            "accessory": {
              "type": "static_select",
              "placeholder": {
                "type": "plain_text",
                "emoji": true,
                "text": "例: さすが"
              },
              "options": [
                {
                  "text": {
                    "type": "plain_text",
                    "emoji": true,
                    "text": "さすが"
                  },
                  "value": "value-0"
                },
                {
                  "text": {
                    "type": "plain_text",
                    "emoji": true,
                    "text": "すぐ"
                  },
                  "value": "value-1"
                },
                {
                  "text": {
                    "type": "plain_text",
                    "emoji": true,
                    "text": "おそれず"
                  },
                  "value": "value-2"
                },
                {
                  "text": {
                    "type": "plain_text",
                    "emoji": true,
                    "text": "みずから"
                  },
                  "value": "value-3"
                }
              ]
            }
          },
          {
            "dispatch_action": true,
            "type": "input",
            "element": {
              "type": "plain_text_input",
              "dispatch_action_config": {
                "trigger_actions_on": [
                  "on_character_entered"
                ]
              },
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
                "value": "click_me_123"
              }
            ]
          }
        ]
      }"
    encoded_msg = ERB::Util.url_encode(msg)
    encoded_msg
  end
end
