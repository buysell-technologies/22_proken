class SlackController < ApplicationController
  def create
    @body = JSON.parse(request.body.read)
    case @body['type']
    when 'url_verification'
        render json: @body
    when 'event_callback'
        pp "aa"
    end
end
end
