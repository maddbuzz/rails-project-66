install:
	bin/setup
	bin/rails assets:precompile
	# bin/rails db:seed

without-production:
	bundle config set --local without 'production'

install-without-production: without-production install
	gem install slim_lint
	cp -n .env.example .env || true

dev-start:
	bin/rails s

start:
	bin/rails s -p 3000 -b "0.0.0.0"

console:
	bin/rails console

test:
	clear || true
	bin/rails db:environment:set RAILS_ENV=test
	NODE_ENV=test bin/rails test

test-all:
	bin/rails test:all

test-all-coverage:
	rm -rf coverage
	COVERAGE=1 make test-all

slim-lint:
	slim-lint app/**/*.slim || true

lint: slim-lint
	bundle exec rubocop

lint-fix:
	bundle exec rubocop -A

.PHONY: test
