install:
	bin/setup
	bin/rails assets:precompile
	# bin/rails db:seed

without-production:
	bundle config set --local without 'production'

install-without-production: without-production install
	gem install slim_lint
	# cp -f .env.example .env || true

dev-start:
	RAILS_ENV=development bin/rails assets:precompile
	bin/rails s -p 3000 -b "localhost"

start:
	bin/rails s -p 3000 -b "0.0.0.0"

console:
	bin/rails console

test:
	clear || true
	bin/rails db:environment:set RAILS_ENV=test
	NODE_ENV=test bin/rails test

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
