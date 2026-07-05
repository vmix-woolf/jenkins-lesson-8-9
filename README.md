## Jenkins, Helm, Terraform, Argo CD

### 1. Опис проєкту

У цьому проєкті реалізовано CI/CD та GitOps-доставку Django-застосунку в Amazon EKS.

Інфраструктура створюється через Terraform:

- VPC;
- ECR;
- EKS;
- Jenkins через Helm;
- Argo CD через Helm;
- Jenkins pipeline для збірки Docker image;
- Argo CD Application для автоматичної доставки Helm chart у Kubernetes.

Основна гілка для здачі домашнього завдання:

```bash
lesson-8-9
```

Jenkins pipeline після успішної збірки оновлює тег Docker image у `charts/django-app/values.yaml` і пушить зміну в `main`, як зазначено в ТЗ.

---

### 2. Архітектура CI/CD

Схема роботи:

```text
Developer push
        ↓
Jenkins pipeline
        ↓
Kaniko build Docker image
        ↓
Push image to Amazon ECR
        ↓
Update Helm values.yaml in Git
        ↓
Push changes to main
        ↓
Argo CD detects Git change
        ↓
Argo CD syncs Helm chart
        ↓
Django app updated in EKS
```

---

### 3. Структура проєкту

```text
.
├── app/
│   ├── Dockerfile
│   ├── manage.py
│   └── ...
├── charts/
│   └── django-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
├── modules/
│   ├── ecr/
│   ├── eks/
│   ├── jenkins/
│   ├── network/
│   └── argo_cd/
├── Jenkinsfile
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

### 4. Terraform backend

Terraform state зберігається у S3 backend:

```hcl
bucket       = "terraform-state-lesson-8-9-mykhailov-viacheslav-20260628"
key          = "lesson-8-9/terraform.tfstate"
region       = "us-west-2"
use_lockfile = true
```

Перед запуском потрібно ініціалізувати Terraform:

```bash
terraform init
```

---

### 5. Змінні середовища

Для доступу Argo CD до GitHub використовується SSH private key, який передається через Terraform variable.

Ключ не зберігається в Git.

Перед `terraform plan` або `terraform apply` потрібно виконати:

```bash
export TF_VAR_github_ssh_private_key="$(cat ~/.ssh/jenkins_lesson_8_9_rsa)"
```

---

### 6. Запуск Terraform

Перевірка форматування:

```bash
terraform fmt -recursive
```

Валідація:

```bash
terraform validate
```

План:

```bash
terraform plan
```

Застосування інфраструктури:

```bash
terraform apply
```

Для окремого застосування Jenkins модуля:

```bash
terraform apply -target=module.jenkins
```

Для окремого застосування Argo CD модуля:

```bash
terraform apply -target=module.argo_cd
```

---

### 7. Jenkins

Jenkins встановлюється через Terraform + Helm у namespace:

```text
jenkins
```

Перевірка Jenkins:

```bash
kubectl get pods -n jenkins
kubectl get svc -n jenkins
```

Очікуваний результат:

```text
jenkins-0   2/2   Running
```

Jenkins використовує Kubernetes agent з двома основними контейнерами:

- `kaniko` — збірка та push Docker image в ECR;
- `git` — оновлення `values.yaml`, commit і push у GitHub.

Pipeline описаний у файлі:

```text
Jenkinsfile
```

Основні етапи Jenkins pipeline:

```text
checkout
generate image tag
build and push image with kaniko
update helm values
commit and push helm values
```

Успішна збірка завершується статусом:

```text
Finished: SUCCESS
```

---

### 8. Amazon ECR

Docker image Django-застосунку пушиться в Amazon ECR:

```text
894662486142.dkr.ecr.us-west-2.amazonaws.com/lesson-8-9-ecr
```

Перевірка image в ECR:

```bash
aws ecr describe-images \
  --repository-name lesson-8-9-ecr \
  --region us-west-2 \
  --query 'imageDetails[*].imageTags'
```

---

### 9. Argo CD

Argo CD встановлюється через Terraform + Helm у namespace:

```text
argocd
```

Перевірка Argo CD:

```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
kubectl get applications -n argocd
```

Очікуваний результат для Application:

```text
django-app   Synced   Healthy
```

Argo CD Application налаштований на:

```text
repoURL: git@github.com:vmix-woolf/jenkins-lesson-8-9.git
targetRevision: main
path: charts/django-app
destination namespace: django-app
```

Автоматична синхронізація увімкнена:

```yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

---

### 10. Django app у Kubernetes

Django-застосунок розгортається Argo CD у namespace:

```text
django-app
```

Перевірка pod:

```bash
kubectl get pods -n django-app
```

Перевірка service:

```bash
kubectl get svc -n django-app
```

Перевірка image tag у Deployment:

```bash
kubectl get deployment django-app -n django-app \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Приклад очікуваного image:

```text
894662486142.dkr.ecr.us-west-2.amazonaws.com/lesson-8-9-ecr:8f3ff5c
```

---

### 11. GitOps-перевірка

Після успішного Jenkins build:

1. Jenkins збирає Docker image через Kaniko.
2. Image пушиться в Amazon ECR.
3. Jenkins оновлює тег image у `charts/django-app/values.yaml`.
4. Jenkins пушить зміну в `main`.
5. Argo CD бачить зміну в Git.
6. Argo CD автоматично синхронізує Helm chart.
7. Deployment у namespace `django-app` отримує новий image tag.

Перевірка статусу Argo CD:

```bash
kubectl get applications -n argocd
```

Детальна перевірка:

```bash
kubectl describe application django-app -n argocd
```

Успішний результат:

```text
Sync Status: Synced
Health Status: Healthy
Message: successfully synced
```

---

### 12. Видалення ресурсів

У проєкті створюються платні AWS-ресурси:

- EKS cluster;
- EC2 worker nodes;
- NAT Gateway;
- Load Balancer для Jenkins;
- Load Balancer для Argo CD;
- ECR repository;
- VPC resources.

Після перевірки домашнього завдання ресурси потрібно видалити.

Основна команда:

```bash
terraform destroy
```

Перед видаленням потрібно переконатися, що змінна з GitHub SSH key доступна:

```bash
export TF_VAR_github_ssh_private_key="$(cat ~/.ssh/jenkins_lesson_8_9_rsa)"
```

Потім:

```bash
terraform destroy
```

Після завершення можна перевірити, що Kubernetes-ресурси більше недоступні:

```bash
kubectl get nodes
```

Якщо кластер видалено, команда поверне помилку підключення, що є очікуваним результатом.

---

### 13. Результат

У результаті виконання ДЗ реалізовано:

- інфраструктуру AWS через Terraform;
- EKS cluster;
- ECR repository;
- Jenkins через Helm;
- Jenkins pipeline з Kaniko;
- автоматичне оновлення Helm values;
- Argo CD через Helm;
- Argo CD Application;
- автоматичну GitOps-синхронізацію Django app;
- оновлення Deployment без ручного деплою.