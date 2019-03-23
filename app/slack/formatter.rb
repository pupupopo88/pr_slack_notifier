module Slack
  class Formatter
    def initialize(file_name=nil)
      return if file_name.nil?

      file = "config/#{file_name}"
      return unless File.exist?(file)

      dic_data = YAML.load_file(file)
      # HACK: 第一階層しかtransformしてくれなかったのでどうしよ
      @dictionary = dic_data.transform_keys(&:to_sym) if dic_data
    end

    # 渡したリポジトリ全部を以下のように表示できる形で返す
    # *リポジトリ名*
    # リンク付きプルリクタイトル1
    # リンク付きプルリクタイトル2
    def repos_to_text(repos, options={})
      # 渡したデータがカラ
      return t(:nothing_data) if repos.empty?

      texts = repos.map do |repo|
        next if repo.pulls.empty?

        # repos用のメッセージを除いたオプション渡す
        pulls_options = options.reject { |key| key == :message }
        pulls_text = pulls_to_text(repo.pulls, pulls_options)

        # プルリクのテキストがあった時だけ頭にリポジトリ名つける
        pulls_text.nil? ? nil : "#{repo.name}\n#{pulls_text}"
      end.compact

      # プルリクなどなかった
      return result_msg(options[:message], :not_found) if texts.empty?

      text = texts.join("\n")
      # メッセージ付きで返す
      "#{result_msg(options[:message], :found)}#{text}"
    end

    # 渡したプルリクエスト全部を以下のように表示できる形で返す
    # リンク付きプルリクタイトル1
    # リンク付きプルリクタイトル2
    def pulls_to_text(pulls, options={})
      # 対象となっているプルリクから更に絞り込みたい
      pulls = select_pulls(pulls, options[:select])
      texts = pulls.map { |pull| link_text(pull.html_url, pull.title) }

      # プルリクなどなかった
      return result_msg(options[:message], :not_found) if texts.empty?

      text = texts.join("\n")
      # メッセージ付きで返す
      "#{result_msg(options[:message], :found)}#{text}"
    end

    private

    def select_pulls(pulls, condition)
      return pulls if condition.nil?

      now = Time.now.getlocal("+09:00")
      case condition
      when :near_deadline
        # とりあえず休みもあるだろうし5日前にしとく
        pulls.select { |pull| !verified?(pull) && pull.deadline && pull.deadline - (60 * 60 * 24 * 5) <= now }
      when :deadline
        pulls.select { |pull| !verified?(pull) && pull.deadline && pull.deadline <= now }
      end
    end

    # 確認済み
    def verified?(pull)
      pull.title.match?(/確認済/)
    end

    # プルリク検索結果用のメッセージを返す
    def result_msg(msg_key, type)
      msg = @dictionary&.dig(msg_key, type.to_s)
      return nil if msg.nil?

      "#{msg}\n"
    end

    # 辞書ファイルからメッセージを引っ張ってくる
    def translate(key)
      return nil unless @dictionary&.has_key?(key)

      "#{@dictionary[key]}\n"
    end
    alias :t :translate

    # Slackにリンク付き文字を表示させる形式にする
    def link_text(url, text)
      "<#{url}|#{text}>"
    end
  end
end
