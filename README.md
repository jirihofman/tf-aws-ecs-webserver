This repository is a part of proof of concept for a simple application managing automated instance provisioning and deployment.

## Terraform
This simple module is used to create an AWS ECS cluster and service for the application.

## GitHub Actions
### Running Terraform
Triggered manually or via GitHub API called from the admin application.
```sh
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token <GH_TOKEN>" \
  https://api.github.com/repos/jirihofman/tf-aws-ecs-webserver/actions/workflows/cluster-buffer-create.yml/dispatches \
  -d '{
    "ref": "master",
    "inputs": {
      "subdomain": "dev1"
    }
  }'
```
### Updating buffer in admin application
```sh
curl -X POST "<ADMIN_APP_URL>" \
-d '{
	"subdomain": "foo",
	"url": "https://foo.bar.com"
}'
