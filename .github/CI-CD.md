# CI/CD

The CI/CD process works on the principle of Build Once, Deploy Many.

There are 3 different workflows:

* Flask CI Build and Deploy to Dev
* Promote to Staging
* Promote to Production

## Flask CI Build and Deploy to Dev

The workflow starts when pushing to the dev branch with changes
in the following paths:

```
- 'app/**'
- 'tests/**'
- '.github/workflows/ci.yaml'
```

Excluding Markdown files with the following patterns:

```
- '!**/*.MD'
- '!**/*.md'
```

The workflow can also be started manually using the "Run workflow" button.

There are 3 jobs in this workflow:

1. **Changes** - Checks which files were changed in the app folder,
   excluding Markdown files.

2. **Tests** - Uses Ruff to check Python files in the app and tests
   folders for common issues, and Pytest to test the home and health endpoints.

3. **Build** - Runs after both previous jobs finish successfully,
   and only if application files were changed or the workflow
   was started manually on the dev branch.

This was done to avoid unnecessary image builds and pushes to Docker Hub.

After building the image, the container is started and the health
endpoint is checked.

If the health check passes, the image is pushed to Docker Hub
using the short commit SHA as the image tag.

The workflow then updates values-dev.yaml and pushes the changes
to the dev branch, allowing Argo CD to deploy the new image.

## Promote to Staging

The workflow starts when a Pull Request is merged into the main branch.

There is one job in this workflow - "promote".

The job runs only if the Pull Request was merged and comes from the dev branch.

It takes the image tag from values-dev.yaml and validates that it contains between 7 and 10 hexadecimal characters.

The workflow then updates the image tag in values-staging.yaml and commits and pushes the changes to the main branch.

Argo CD detects the changes and deploys the image to the Staging environment.

## Promote to Production

The workflow starts manually by clicking the "Run workflow" button.

There is one job in this workflow - "promote".

It takes the image tag from values-staging.yaml and validates that it contains between 7 and 10 hexadecimal characters.

The workflow updates values-prod.yaml, creates a new branch from main, and opens a Pull Request to main.

To prevent accidental deployments to Production, there are two manual steps:

1. Running the workflow to create the Pull Request.
2. Reviewing and merging the Pull Request.

Argo CD detects the changes after the merge and deploys the image to the Production environment.

In a real production environment, we would use Branch Protection and CODEOWNERS to require approval from a Team Leader or a DevOps Engineer before merging.