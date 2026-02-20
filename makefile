# Налаштування
TF_DIR = .
TEST_DIR = ./test
CHECK_DIR = ./checkov_rules
LOCALSTACK_URL = http://localhost:4566

.PHONY: all setup scan test clean

# 1. Запуск всього циклу
all: setup scan test

# 2. Підготовка середовища (Minikube та LocalStack)
setup:
	@echo "--- Запуск Minikube та LocalStack ---"
	minikube status || minikube start
	@if ! helm list | grep -q localstack; then \
		helm repo add localstack https://localstack.github.io; \
		helm install localstack localstack/localstack --set startServices="s3"; \
	fi
	@echo "Очікування готовності LocalStack..."
	kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=localstack --timeout=60s

# 3. Статичний аналіз безпеки (Checkov)
scan:
	@echo "--- Запуск Checkov (Static Analysis) ---"
	# Перевірка на відкритий 22 порт та публічні S3
	checkov -d $(TF_DIR) --external-checks-dir $(CHECK_DIR) \
		--check CUSTOM_K8S_22,CKV_AWS_20,CKV_AWS_24 \
		--soft-fail false

# 4. Інтеграційні тести (Terratest)
test:
	@echo "--- Запуск Terratest (Integration Tests) ---"
	cd $(TEST_DIR) && go mod tidy && go test -v -timeout 30m

# 5. Очищення ресурсів
clean:
	@echo "--- Видалення ресурсів ---"
	cd $(TF_DIR) && terraform destroy -auto-approve
	helm uninstall localstack
	minikube stop

# Допоміжна команда для перевірки S3 в LocalStack
check-s3:
	aws --endpoint-url=$(LOCALSTACK_URL) s3 ls
