module GitHub
  class Repository
    attr_reader :name, :api_url, :html_url, :pulls

    @notify_trg = GitHub::SETTINGS.dig('notify', 'repos') || {}

    class << self
      # チームIDからリポジトリのリストを引っ張ってくる
      # [
      #   <#GitHub::Repository>,
      #   <#GitHub::Repository>
      # ]
      def get_by_team_id(id)
        repos_json = Client.get("/teams/#{id}/repos")
        repos_json.map do |repo|
          # 除外リストに入ってたら飛ばす
          next if ignore?(repo)

          self.new(repo)
        end.compact
      end

      private

      # 通知除外のリポジトリかどうか
      # とりあえず除外するリポジトリ名だけ
      def ignore?(repo)
        @ignore = @notify_trg.dig('ignore')
        # そもそも定義ファイルにない
        return false if @ignore.nil?
        # ignoreリストに書いてある
        return true if @ignore.dig('name')&.include?(repo['name'])

        false
      end
    end

    def initialize(json)
      @name = json['name']
      @api_url = json['url']
      @html_url = json['html_url']
      @pulls = PullRequest.get_by_full_name(json['full_name'])
    end
  end
end
