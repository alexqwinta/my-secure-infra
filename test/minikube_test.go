go
package test

import (
	"testing"
	"://github.com"
	"://github.com"
	"://github.com"
)

func TestTerraformK8sMinikube(t *testing.T) {
	t.Parallel()

	options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Шлях до папки з Terraform кодом
		TerraformDir: "../",
	})

	// В кінці тесту виконати 'terraform destroy'
	defer terraform.Destroy(t, options)

	// Виконати 'terraform init' та 'terraform apply'
	terraform.InitAndApply(t, options)

	// Перевірка результату в Minikube
	namespaceName := "my-apps"
	kubectlOptions := k8s.NewKubectlOptions("", "", namespaceName)
	
	// Перевіряємо, чи існує наш Namespace
	ns := k8s.GetNamespace(t, kubectlOptions, namespaceName)
	assert.Equal(t, ns.Name, namespaceName)
}
