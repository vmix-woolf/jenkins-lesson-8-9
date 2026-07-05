# Terraform module: RDS / Aurora

## Опис

У цьому модулі реалізовано універсальний Terraform-модуль для створення бази даних в AWS.

Модуль може створювати:

- звичайну RDS instance;
- Aurora cluster з writer instance.

Режим роботи вибирається через змінну `use_aurora`.

## Що зроблено

У модулі реалізовано:

- умовне створення звичайної RDS через `aws_db_instance`;
- умовне створення Aurora через `aws_rds_cluster` та `aws_rds_cluster_instance`;
- створення `aws_db_subnet_group`;
- створення `aws_security_group`;
- створення `aws_db_parameter_group`;
- створення `aws_rds_cluster_parameter_group`;
- змінні з типами, описами та default-значеннями;
- outputs для endpoint, port, database identifier, security group id та subnet group name.

## Структура модуля

```text
modules/rds/
├── shared.tf
├── rds.tf
├── aurora.tf
├── variables.tf
└── outputs.tf
```

## Приклад використання

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "lesson-db-module"
  use_aurora = false

  engine         = "postgres"
  instance_class = "db.t3.micro"

  database_name = "appdb"
  username      = "dbadmin"
  password      = "ChangeMe123456!"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_cidr_blocks = [
    "10.0.0.0/16"
  ]

  multi_az            = false
  publicly_accessible = false

  skip_final_snapshot = true
  deletion_protection = false
}
```

## Перемикання RDS / Aurora

Звичайна RDS PostgreSQL:

```hcl
use_aurora = false
engine     = "postgres"
```

Звичайна RDS MySQL:

```hcl
use_aurora = false
engine     = "mysql"
```

Aurora PostgreSQL:

```hcl
use_aurora = true
engine     = "aurora-postgresql"
```

Aurora MySQL:

```hcl
use_aurora = true
engine     = "aurora-mysql"
```

## Основні параметри

Модуль дозволяє змінювати:

- тип бази даних через `engine`;
- режим RDS або Aurora через `use_aurora`;
- клас інстансу через `instance_class`;
- версію engine через `engine_version`;
- назву бази даних через `database_name`;
- Multi-AZ режим через `multi_az`;
- доступ до бази через `allowed_cidr_blocks` або `allowed_security_group_ids`.

## Перевірка

Для перевірки коду використовуються команди:

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

## Важливо

RDS та Aurora є платними AWS-ресурсами. Перед виконанням `terraform apply` потрібно уважно перевірити `terraform plan`.

Після завершення перевірки створені ресурси потрібно видалити:

```bash
terraform destroy
```

## Результат

Створено гнучкий Terraform-модуль `rds`, який дозволяє з мінімальними змінами перемикатися між звичайною RDS-базою та Aurora-кластером.