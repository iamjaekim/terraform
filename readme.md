# Terraform

this terraform code is configuring 3 tier architecture style from AWS using terraform v0.12.12 with aws provider 2.34.0

you are **REQUIRED** to supply the existing key name at runtime or set up the default value  
you are **REQURIED** to update backend.tf file's bucket and key name 

this terraform code will provision below components:

NETWORKING Resources:
(1) vpc /
(4) subnets /
(2) route tables /
(1) internet gateway /
(1) nat gateway /
(1) elastic ip /
(4) route table associations /

COMPUTE Resources:
(2) application load balancers /
(2) alb target groups /
(2) listeners /
(2) security groups /
(5) security group rules /
(2) launch configurations /
(2) autoscale groups

DB Resources:
(1) mysql /
(1) db subnet group

```terraform
terraform init
terraform apply
```