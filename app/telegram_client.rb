require 'httparty'

module TelegramClient
  module_function

  API_URL = "https://api.telegram.org/bot#{ENV['BOT_TOKEN']}"

  def send_message(chat_id, text)
    HTTParty.post(
      "#{API_URL}/sendMessage",
      body: {
        chat_id: chat_id,
        text: text.strip,
        disable_web_page_preview: true,
        disable_notification: true,
        parse_mode: 'MarkdownV2'
      }.to_json,
      headers: {'Content-Type' => 'application/json'}
    )
  end

  def valid_username?(chat_id, username)
    res = HTTParty.get("#{API_URL}/getChat", query: {chat_id: chat_id})

    return false unless res.success?

    res["result"]["username"].downcase == username.downcase
  end
end
