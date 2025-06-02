require "net/http"
require "json"
require "uri"

class OpenaiChatService
  OPENAI_URI = URI("https://api.openai.com/v1/chat/completions")

  def initialize(api_key: ENV["OPENAI_API_KEY"])
    @api_key = api_key
  end

  def chat(prompt, model: "gpt-4o-mini")
    http = Net::HTTP.new(OPENAI_URI.host, OPENAI_URI.port)
    http.use_ssl = true

    headers = {
      "Authorization" => "Bearer #{@api_key}",
      "Content-Type" => "application/json"
    }

    body = {
      model: model,
      messages: [{ role: "user", content: prompt }]
    }.to_json

    response = http.post(OPENAI_URI.path, body, headers)
    result = JSON.parse(response.body)

    if response.code == "200"
      result.dig("choices", 0, "message", "content")
    else
      Rails.logger.error("OpenAI error: #{result["error"]}")
      nil
    end
  rescue => e
    Rails.logger.error("OpenAI exception: #{e.message}")
    nil
  end
end