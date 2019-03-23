class HttpsClient
  def initialize(options)
    @uri = URI.parse(options[:uri])
    @headers = options[:headers]
    @http = Net::HTTP.new(@uri.host, @uri.port)
    @http.use_ssl = true
  end

  # GitHubAPI用
  def get(path)
    res = @http.get(path, @headers)
    body = JSON.parse(res.body)

    # res.header['link']にnextあったら再帰的にgetして合わせて返す
    next_path = res.header['link']&.match(/<https:\/\/[\w.]+(\/.*)>;\srel=\"next\"/)
    body += get(next_path[1]) if next_path

    body
  end

  # Slack用
  def post(message={})
    return if message.empty?

    @http.post(@uri.request_uri, message.to_json, @headers)
  end
end
