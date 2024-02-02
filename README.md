This repository is a part of PoC for a simple [application managing](https://appmixer-mission-control.vercel.app/provisioning/admin) automated instance provisioning and deployment.

## Terraform
This simple module is used to create an AWS ECS cluster and service for the application.

Inputs: subdomain

## GitHub Actions
There are two actions.

`cluster-buffer-create.yml`
- Creates AWS cluster using the Terraform module.
- The cluster is identified by a subdomain. Subdomain is a random string like `test-yp4m2l`.
- Updates information about the cluster in Admin Application. When this workflow is started, the status of the cluster in the Admin Application is `pending`. Once this workflow is done, it changes it do `ready` and loads information like `url` and `arn`.

`cluster-buffer-delete.yml`
- Destroys AWS cluster and its instances
- The cluster and instances are identified by a subdomain. Subdomain is a random string like `test-yp4m2l`.

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
curl -X POST 'http://localhost:3000/api/provisioning/admin/buffer/provisioned' -H 'Content-Type: application/json' -d '{"subdomain":"test-f49ih"}'
