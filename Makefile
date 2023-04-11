install:
	bin/setup
	bin/rails assets:precompile
	# bin/rails db:seed

without-production:
	bundle config set --local without 'production'

install-without-production: without-production install
	slim-lint -v || gem install slim_lint
	cp -n .env.example .env || true

dev-start:
	#
	# Для того, чтобы проверить github_webhook'и локально, можно использовать программу для создания HTTP-туннелей (ngrok.com)
	# Но нужно будет заполнить соответствующие значения в .env для BASE_URL, GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET.
	# BASE_URL вообще будет каждый раз меняться при перезапуске ngrok, поэтому помимо .env нужно будет его менять
	# и в приложении OAuth https://github.com/settings/applications/2162079
	# ~/ngrok.dir/ngrok http 3000
	#
	bin/rails s -p 3000

start:
	bin/rails s -p 3000 -b "0.0.0.0"

console:
	bin/rails console

test:
	clear || true
	bin/rails db:environment:set RAILS_ENV=test
	NODE_ENV=test bin/rails test

test-coverage:
	rm -rf coverage
	COVERAGE=1 make test

test-system:
	clear || true
	rm -rf tmp/screenshots/ || true
	firefox -v || sudo apt install -y firefox
	bin/rails db:environment:set RAILS_ENV=test
	NODE_ENV=test bin/rails test:system

test-system-headless:
	MOZ_HEADLESS=1 make test-system

slim-lint:
	slim-lint app/**/*.slim || true

lint: slim-lint
	bundle exec rubocop

lint-fix:
	bundle exec rubocop -A

.PHONY: test
