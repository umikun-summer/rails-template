BASE_REPOSITORY_URL = 'https://raw.githubusercontent.com/umikun-summer/rails-template/main/%s'.freeze
FILES = %w[
  .rubocop.yml
  .haml-lint.yml
  config/locales/ja.yml
].freeze

gem 'sgcop', github: 'SonicGarden/sgcop', branch: 'main'
gem 'haml_lint', require: false

FILES.each do |file_path|
  get BASE_REPOSITORY_URL % file_path, file_path
end

remove_file 'config/locales/en.yml'