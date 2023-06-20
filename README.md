[![Actions Status](https://github.com/maddbuzz/rails-project-66/actions/workflows/CI.yml/badge.svg)](https://github.com/maddbuzz/rails-project-66/actions/workflows/CI.yml)
[![Actions Status](https://github.com/maddbuzz/rails-project-66/workflows/hexlet-check/badge.svg)](https://github.com/maddbuzz/rails-project-66/actions)

## «Github Quality» *(graduation project of the profession «Ruby on Rails Developer»)*
The Github Quality project is a service that helps you automatically monitor the quality of github repositories. It tracks changes and runs them through the built-in parsers. Then it generates reports and sends them to the user.

(production deployed on [render](https://maddbuzz-rails-github-quality.onrender.com))

## Local installation
```
make install-without-production
```
(after that fill *.env* file with correct values)
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
