module GitHub
  file = 'config/github.yml'
  SETTINGS = File.exist?(file) ? YAML.load_file(file) : {}
end
