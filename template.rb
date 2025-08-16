BASE_REPOSITORY_URL = 'https://raw.githubusercontent.com/umikun-summer/rails-template/main/%s'.freeze
FILES = %w[
  .rubocop.yml
  .haml-lint.yml
  config/locales/ja.yml
].freeze

def setup_simple_form
  simple_form_scaffold_template_file = 'lib/templates/haml/scaffold/_form.html.haml'
  simple_form_scaffold_locale_file = 'config/locales/simple_form.en.yml'

  generate 'simple_form:install', '--bootstrap'
  remove_file simple_form_scaffold_template_file if File.exist?(simple_form_scaffold_template_file)
  remove_file simple_form_scaffold_locale_file if File.exist?(simple_form_scaffold_locale_file)
end

def create_admins_application_controller
  file_path = 'app/controllers/admins/application_controller.rb'

  run 'mkdir app/controllers/admins'
  get BASE_REPOSITORY_URL % file_path, file_path
end

# ファイルをリモートから取得
FILES.each do |file_path|
  get BASE_REPOSITORY_URL % file_path, file_path
end

# en.yml は不要なので削除
remove_file 'config/locales/en.yml'

# 追加するgem
gem 'sgcop', github: 'SonicGarden/sgcop', branch: 'main'
gem 'haml_lint', require: false
gem 'simple_form'
gem 'haml-rails'
gem 'html2haml' # 一時的に使用する

after_bundle do
  # Gemfile を自動修正
  run 'bundle exec rubocop -a Gemfile'

  # simple_form を bootstrapでセットアップ
  setup_simple_form

  if yes?('管理者画面を追加しますか？ [y/n]')
    create_admins_application_controller
  end

  # erbをhamlに変換
  run "yes 'n' | bin/rails haml:erb2haml"
  gsub_file 'Gemfile', /gem 'html2haml'/, ''
  run 'bundle install'
end
