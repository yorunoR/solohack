# -*- coding: utf-8 -*-

# Railsのルートパスを求める。(RAILS_ROOT/config/unicorn.rbに配置している場合。)
rails_root = File.expand_path('../../', __FILE__) + '/'

# RAILS_ENVを求める。（RAILS_ENV毎に挙動を変更したい場合に使用。今回は使用しません。)
rails_env = ENV['RAILS_ENV'] || "development"

# 追記に記載してます。入れた方がいいです。For Capistrano
ENV['BUNDLE_GEMFILE'] = rails_root + "Gemfile"

# Unicornは複数のワーカーで起動するのでワーカー数を定義
# サーバーのメモリなどによって変更すること。
worker_processes 1

# 指定しなくても良い。
# Unicornの起動コマンドを実行するディレクトリを指定します。
# （記載しておけば他のディレクトリでこのファイルを叩けなくなる。）
working_directory rails_root

# Nginxで使用する場合は以下の設定を行う。
# listen File.expand_path('../../tmp/sockets/unicorn.sock', __FILE__)
# listen "/tmp/unicorn.sock"
listen rails_root + "tmp/sockets/unicorn.sock"
# とりあえず起動して動作確認をしたい場合は以下の設定を行う。
# listen 8080

# プロセスの停止などに必要なPIDファイルの保存先を指定。
pid rails_root + "tmp/pids/unicorn.pid"

# Unicornのエラーログと通常ログの位置を指定。
if rails_env != 'development'
  stderr_path rails_root + "log/unicorn_stderr.log"
  stdout_path rails_root + "log/unicorn_stdout.log"
end

# 接続タイムアウト時間
timeout 30

# 基本的には`true`を指定する。Unicornの再起動時にダウンタイムなしで再起動が行われる。
preload_app true

# USR2シグナルを受けると古いプロセスを止める。
# 後述するが、記述しておくとNginxと連携する時に良いことがある。
before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
