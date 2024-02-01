This module is used to create an AWS ECS cluster and service for the application.

```sh
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token YOUR_GITHUB_TOKEN" \
  https://api.github.com/repos/OWNER/REPO/actions/workflows/WORKFLOW_ID_OR_FILE_NAME/dispatches \
  -d '{
    "ref": "main",
    "inputs": {
      "subdomain": "YOUR_SUBDOMAIN"
    }
  }'
```
