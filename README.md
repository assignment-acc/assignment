# Assignment

The repository contains code to deploy, protect and monitor [`juice-shop` application]
(https://github.com/secureCodeBox/secureCodeBox/tree/main/demo-apps/juice-shop). The application supposed to be deployed to a Kubernetes cluster.

## Requirements

For the application to be deployed successfully, the following are required:

- Kubernetes cluster (please see [`Setting up local Kubernetes cluster` section](#Setting-up-local-Kubernetes-cluster).
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- AWS account (optional, only required for external DNS records)

### Setting up local Kubernetes cluster

For testing purporse, you can create a new Kubernetes cluster by following these steps:

1. Download and install [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation).
1. Run `kind create cluster --name assignment --config kind.yaml` command

## Configuring

The provided Terraform configuration supports a number of variables to customize the deployment behaviour.

| Variable                     | Description                                                       | Default Value       |
|------------------------------|-------------------------------------------------------------------|---------------------|
| `kube_config`                | Path to Kubernetes configuration file                             | `~/.kube/config`    |
| `kube_context`               | Name of Kubernetes cluster context to use                         | `kind-assignment`   |
| `kube_cluster_ip`            | IP (either local or external one) of the Kubernetes cluster       | `127.0.0.1`         |
| `aws_region`                 | Name of AWS region to use for external DNS records.               | `eu-west-1`         |
| `aws_credentials.access_key` | Credentials with access to created records in AWS Route53         |                     |
| `aws_credential.secret_key`  | Credentials with access to created records in AWS Route53         |                     |
| `versions`                   | Helm chart versions to deploy                                     | `latest`            |
| `grafana_password`           | Password for Grafana administrator account                        |                     |
| `dns_zone`                   | Zone to create DNS records for deployed applications in           | `.assignment.local` |
| `deploy_ingress_nginx`       | Whether the Nginx-based ingress should be deployed to the cluster | `true`



You can set the parameters by passing `-var name=value` to `terraform apply` command or using any other method defined in [official Terraform documentation](https://www.terraform.io/docs/language/values/variables.html#assigning-values-to-root-module-variables).

## Deploying

1. Checkout the repository.
1. Run `terraform init .\terraform`.
1. Run `terraform apply .\terraform`.
1. Provide Grafana administrator password when prompted.
1. Confirm the generated Terraform plan is valid.
1. Type `Yes` to deploy.


## Known limitations

- Applications are not using trusted SSL certificates. The cluster has [`cert-manager`](https://github.com/jetstack/cert-manager) deployed, but enabling automated certificate rotation via custom manifests requires, using [Alpha version of new Terraform Kubernetes provider](https://www.hashicorp.com/blog/deploy-any-resource-with-the-new-kubernetes-provider-for-hashicorp-terraform).
- Alerts are missing (it would be good to have an alert when SLO budget is decreasing, nearing the required 99.95% SLO.
