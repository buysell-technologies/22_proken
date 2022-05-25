.DEFAULT_GOAL := usage
ENV=development

usage:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

set-env:
	@sed -ie 's/\(ENV=\).*/\1${ENV}/' .env
	@grep "^ENV" .env

up: ## コンテナ立ち上げ
	docker-compose up

db-create: ## 最初のdb作成
	docker-compose -f docker-compose.${ENV}.yml exec app  bundle exec rake db:create RAILS_ENV=${ENV}

build: ## Build or rebuild services.
	docker-compose -f docker-compose.${ENV}.yml build

stop: ## Stop running containers without removing them.
	docker-compose stop

bundle: ## bundle install
	docker-compose run --rm app bundle install

console: ## rails console
	docker-compose run --rm app bundle exec rails console

seed_fu: ## マスタデータ投入
	docker-compose run web rails db:seed_fu
