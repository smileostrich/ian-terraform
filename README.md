# Ian-Terraform

## IAM
global IAM(not module)
### Folder
```
.\global
|-- global
```
### Usage
```
$ terraform init
$ terraform output encrypted_aws_iam_secrets
```


## VPC Module
VPC를 위한 모듈
### Folder
```
.\global\vpc
|-- global
|  |-- vpc
```
### Resource
* VPC
* public, private subnet
* Internet Gateway
* Default NACL, Default Security Group
* NAT Gateway(EIP) 1개
* Internet Gateway, NAT Gateway에 Subnet을 연결하는 Route Table, Route Table Association 


## VPC(for EKS)
apne2 eks VPC
### Folder
