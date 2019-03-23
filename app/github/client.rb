module GitHub
  class Client
    @client = HttpsClient.new(
      uri: 'https://api.github.com/',
      headers: {
        'Content-Type' => 'application/vnd.githubv3+json',
        'User-Agent' => 'lambda',
        'Authorization' => "token #{ENV['GITHUB_API_TOKEN']}"
      }
    )

    def self.get(path)
      @client.get(path)
    end
  end
end
