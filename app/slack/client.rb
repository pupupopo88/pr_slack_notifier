module Slack
  class Client
    def initialize(webhook_url)
      @client = HttpsClient.new(
        uri: webhook_url,
        headers: {'Content-Type' => 'application/json'}
      )
    end

    def post(text)
      @client.post({ text: text })
    end
  end
end
