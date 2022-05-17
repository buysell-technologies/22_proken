.DEFAULT_GOAL := usage
environment=development

usage:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

up:
	docker-compose up

build:
	docker-compose build

bundle: ## bundle install
	docker-compose run --rm web bundle install

console: ## rails console
	docker-compose run --rm web bundle exec rails console

seed_fu: ## マスタデータ投入
	docker-compose run web rails db:seed_fu
