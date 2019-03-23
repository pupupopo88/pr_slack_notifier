module GitHub
  class Repository
    class PullRequest
      attr_reader :html_url, :title, :deadline

      @notify_trg = SETTINGS.dig('notify', 'pulls') || {}

      class << self
        # リポジトリのfull_nameからプルリクのリストを引っ張ってくる
        # [
        #   <#GitHub::Repository::PullRequest>,
        #   <#GitHub::Repository::PullRequest>
        # ]
        def get_by_full_name(name)
          pulls_json = Client.get("/repos/#{name}/pulls")
          pulls_json.map do |pull|
            next if ignore?(pull)

            self.new(pull)
          end.compact
        end

        private

        # 通知除外のプルリクかどうか
        # とりあえず除外するタイトルだけ
        def ignore?(pull)
          @ignore = @notify_trg.dig('ignore')
          # そもそも定義ファイルにない
          return false if @ignore.nil?
          # ignoreリストにタイトルで除外する正規表現書いてある
          rex = @ignore.dig('title')&.slice(/\/(.*)\//, 1)
          return false if rex.nil?
          return true if Regexp.new(rex).match?(pull['title'])

          false
        end
      end

      def initialize(json)
        @html_url = json['html_url']
        @title = json['title']
        @deadline = convert_deadline(@title)
      end

      private

      def convert_deadline(str)
        yyyymmdd = str.match(/20\d{6}/).to_a[0]
        return nil if yyyymmdd.nil?

        yyyy = yyyymmdd[0..3]
        mm = yyyymmdd[4..5]
        dd = yyyymmdd[6..7]
        Time.new(yyyy, mm, dd, 23, 59, 59, '+09:00')
      end
    end
  end
end
