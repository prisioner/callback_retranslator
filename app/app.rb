# frozen_string_literal: true

require 'sinatra/base'
require 'dotenv/load'
require 'active_support/inflector'
require 'rspec_api_documentation/curl'
require_relative 'telegram_client'

class CallbackRetranslatorApp < Sinatra::Base
  get "/" do
    <<~PAGE
      Write <a href="https://t.me/CallbackRetranslatorBot">@CallbackRetranslatorBot</a> telegram bot for instructions
    PAGE
  end

  post "/p/:chat_id/:username/?:scope?/" do
    return 200 unless TelegramClient.valid_username?(params[:chat_id], params[:username])

    body = request.body.read
    headers = {
      'Content-Type' => request.env['CONTENT_TYPE']
    }.compact

    TelegramClient.send_message(
      params[:chat_id],
      <<~MESSAGE
        #{"FROM: #{params[:scope]}" if params[:scope]}

        ```
        #{RspecApiDocumentation::Curl.new('POST', '/', body, headers).output('https://example.org')}
        ```
      MESSAGE
    )

    200
  end

  post "/bot#{ENV['BOT_TOKEN']}".gsub(':', '_') do
    parsed_body = JSON.parse(request.body.read)

    return 200 unless parsed_body["message"]
    return 200 unless parsed_body["message"]["text"] == "/start"

    chat_id = parsed_body["message"]["chat"]["id"]
    username = parsed_body["message"]["chat"]["username"]

    TelegramClient.send_message(
      chat_id,
      <<~MESSAGE
        Use provided URL for your POST callback retranslation:

        ```
        #{ENV['HOST_URL']}/p/#{chat_id}/#{username}/?:scope/
        ```
        You may use :scope route variable to specify callback sender — it\\`s value will be included in retranslation message
      MESSAGE
    )

    200
  end
end
