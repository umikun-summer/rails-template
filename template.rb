BASE_REPOSITORY_URL = 'https://raw.githubusercontent.com/umikun-summer/rails-template/main/%s'.freeze
FILES = %w[
  .rubocop.yml
  .haml-lint.yml
  config/locales/ja.yml
].freeze

# ファイルをリモートから取得
FILES.each do |file_path|
  get BASE_REPOSITORY_URL % file_path, file_path
end

# 追加するgem
gem 'sgcop', github: 'SonicGarden/sgcop', branch: 'main'
gem 'haml_lint', require: false
gem 'simple_form'
gem 'haml-rails'
gem 'html2haml' # 一時的に使用する

# en.yml は不要なので削除
remove_file 'config/locales/en.yml'

# database.yml をgitにpushしないように設定
run 'cp config/database.yml config/database.yml.sample'
run "echo 'config/database.yml' >> .gitignore"

after_bundle do
  # Gemfile を自動修正
  run 'bundle exec rubocop -a Gemfile'

  # simple_form を bootstrapでセットアップ
  generate 'simple_form:install', '--bootstrap'
  simple_form_scaffold_template_file = 'lib/templates/haml/scaffold/_form.html.haml'
  remove_file simple_form_scaffold_template_file if File.exist?(simple_form_scaffold_template_file)

  # 認証機能を追加するかどうか確認
  if yes?('認証機能を追加しますか？ [y/n]')
    generate('authentication')
  end

  # 管理画面を用意するかどうか確認
  if yes?('管理者画面を追加しますか？ [y/n]')
    create_admins_application_controller
  end

  # erbをhamlに変換
  run "yes 'n' | bin/rails haml:erb2haml"
  gsub_file 'Gemfile', /gem 'html2haml'/, ''
  run 'bundle install'
end

def create_admins_application_controller
  file_path = 'app/controllers/admins/application_controller.rb'

  run 'mkdir app/controllers/admins'
  get BASE_REPOSITORY_URL % file_path, file_path
end
