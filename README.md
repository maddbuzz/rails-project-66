[![Actions Status](https://github.com/maddbuzz/rails-project-66/actions/workflows/CI.yml/badge.svg)](https://github.com/maddbuzz/rails-project-66/actions/workflows/CI.yml)
[![Actions Status](https://github.com/maddbuzz/rails-project-66/workflows/hexlet-check/badge.svg)](https://github.com/maddbuzz/rails-project-66/actions)

## Github Quality project
The Github Quality project is a service that helps you automatically monitor the quality of github repositories. It tracks changes and runs them through the built-in parsers. Then it generates reports and sends them to the user.

<!-- (production deployed on [railway](https://maddbuzz-rails-bulletin-board.up.railway.app/)) -->

## Local installation
```
make install-without-production
```
## Start dev-server
```
make dev-start
```
## Start linters
```
make lint
```
## Start tests
```
make test
```
## Start system tests (Firefox or Firefox headless)
```
make test-system
```
or
```
make test-system-headless
```
