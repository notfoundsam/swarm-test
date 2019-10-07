PROFILE = aws-swarm

STG = staging
PROD = production

ALL: install
setup-aws:
	pip3 install --upgrade awscli
	aws configure --profile $(PROFILE)
setup-awseb:
	pip3 install --upgrade awsebcli 
	eb init --profile $(PROFILE)
install:
	docker-compose build
	docker-compose up -d
	docker-compose exec web composer install --ignore-platform-reqs --no-interaction --no-plugins --no-scripts --prefer-dist
migrate:
	docker-compose exec web php artisan migrate
rollback:
	docker-compose exec web php artisan migrate:rollback
console:
	docker-compose exec web php artisan tinker
build:
	docker-compose -f docker-compose.yml build
build-prod:
	docker-compose -f docker-compose.yml build
up:
	docker-compose -f docker-compose.yml up -d
	@echo "[web]   http://localhost:8080"
	@echo "[email] http://localhost:1080"
	@echo "[db]    http://localhost:3340"
stop:
	docker-compose -f docker-compose.yml stop
bash:
	docker-compose -f docker-compose.yml exec web bash
ps:
	docker-compose ps
prod:
	npm run build
watch:
	npm run watch
deploy-stg:
	eb deploy --profile $(PROFILE) $(STG)
deploy-prod:
	eb deploy --profile $(PROFILE) $(PROD)
ssh-stg:
	eb ssh --profile $(PROFILE) $(STG)
ssh-prod:
	eb ssh --profile $(PROFILE) $(PROD)
ssh-stg-setup:
	eb ssh --setup --profile $(PROFILE) $(STG)
ssh-prod-setup:
	eb ssh --setup --profile $(PROFILE) $(PROD)
