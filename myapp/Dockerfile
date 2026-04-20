FROM ruby:3.2.2

# 必要なパッケージ
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV RAILS_ENV=production

# Gemインストール
COPY Gemfile Gemfile.lock ./
RUN bundle lock --add-platform x86_64-linux && \
    bundle install

# アプリコピー
COPY . .

# Windows由来の改行コードと権限をLinux用に強制変換
RUN chmod +x bin/* && \
    sed -i 's/\r$//' bin/*

# アセットコンパイル（DB接続を完全にスキップ）
RUN RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 \
    bundle exec rake assets:precompile

# CMD ["sh", "-c", "mkdir -p storage tmp/pids && rm -f tmp/pids/server.pid && bundle exec rails db:prepare && bundle exec rails s -e production -p 3000 -b 0.0.0.0"]
ENTRYPOINT ["sh", "-c", "mkdir -p storage tmp/pids && rm -f tmp/pids/server.pid && (bundle exec rails db:migrate || bundle exec rails db:schema:load) && bundle exec rails s -e production -p 3000 -b 0.0.0.0"]