BASE_REPOSITORY_URL = 'https://raw.githubusercontent.com/umikun-summer/rails-template/main/%s'.freeze

FILES = %w[
  .rubocop.yml
  .haml-lint.yml
  config/locales/ja.yml
].freeze

# 追加するgem
gem 'sgcop', github: 'SonicGarden/sgcop', branch: 'main'
gem 'haml_lint', require: false
gem 'simple_form'
gem 'haml-rails'
gem 'html2haml' # 一時的に使うだけ

# ファイルをリモートから取得
FILES.each do |file_path|
  get BASE_REPOSITORY_URL % file_path, file_path
end

# en.yml は不要なので削除
remove_file 'config/locales/en.yml'

after_bundle do
  # Gemfile を自動修正
  run 'bundle exec rubocop -a Gemfile'

  # simple_form を bootstrap連携でセットアップ
  generate 'simple_form:install', '--bootstrap'

  # simple_form が作る scaffold用テンプレートを削除
  simple_form_scaffold_template_file = 'lib/templates/haml/scaffold/_form.html.haml'
  remove_file simple_form_scaffold_template_file if File.exist?(simple_form_scaffold_template_file)

  # haml-rails 標準の変換タスクで .haml を作成 (erbファイルは残す)
  run "yes 'n' | bin/rails haml:erb2haml"

  # html2haml はもう不要なので Gemfile から削除
  gsub_file 'Gemfile', /gem 'html2haml'/, ''

  # bundle install で反映
  run 'bundle install'

  # 認証機能を追加するかどうか確認
  if yes?('認証機能を追加しますか？ [y/n]')
    generate('authentication')
  end

  # 管理画面を用意するかどうか確認
  if yes?('管理者画面を追加しますか？ [y/n]')
    create_admins_application_controller
  end
end

def create_admins_application_controller
  file_path = 'app/controllers/admins/application_controller.rb'

  run 'mkdir app/controllers/admins'
  get BASE_REPOSITORY_URL % file_path, file_path
end
