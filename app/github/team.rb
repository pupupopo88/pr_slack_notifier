module GitHub
  class Team
    class << self
      # チームIDからリポジトリのリストを引っ張ってくる
      # [
      #   <#GitHub::Repository>,
      #   <#GitHub::Repository>
      # ]
      def find(org_name, team_name)
        teams_json = Client.get("/orgs/#{org_name}/teams")
        team_json = teams_json.find { |team| team['name'] == team_name }
        return nil if team_json.nil?

        self.new(team_json)
      end
    end

    def initialize(json)
      return nil if json.nil?

      @name = json['name']
      @id = json['id']
      @html_url = json['html_url']
    end

    def get_repos
      Repository.get_by_team_id(@id)
    end
  end
end
