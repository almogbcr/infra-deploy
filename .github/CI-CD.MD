# CI/CD

The project uses `main` as its long-lived source branch and two workflows:
`CI` and `Promotion`. The Development environment remains a namespace in the
DEV cluster; it does not require a separate Git branch.

## CI

CI runs on pull requests targeting main, pushes to main and manual dispatch.

* **changes** detects release-related changes, excluding Markdown files.
* **tests** runs Ruff and Pytest for the application.
* **helm** lints and renders the chart for all three environments.
* **build** builds and publishes an image after the checks pass, for eligible
  pushes to main or a manual run on main.

The release paths are `app/**`, `tests/**`, `helm/webapp/**` and
`.github/workflows/ci.yaml`. A push changing only Argo CD release pointers or
documentation runs checks without building another image. Pull request runs
do not publish images.

The build job starts the built container and checks `/health` before pushing
it to Docker Hub. Image tags contain the full source SHA, run ID and attempt.
The job reads the registry digest and uploads `release.json` as the artifact
`release-<run ID>-<attempt>`, retained for 90 days.

Release metadata records the source revision, image repository, digest, tag,
run ID and attempt. Deployment uses the digest rather than the tag.

Required repository configuration:

* Variable `DOCKERHUB_USERNAME` and secret `DOCKERHUB_TOKEN`.
* Permission for GitHub Actions to create pull requests.
* The allowed image repository in Promotion currently is `almogbcr/flask-app`.
  Update that setting alongside the Docker Hub configuration if moving images.

## Promotion

Run **Promotion** from main using **Run workflow**. Select `dev`, `staging`
or `production`, and provide a successful CI run ID that produced a release
artifact.

The workflow validates that the run belongs to this repository's CI workflow,
ran on main through a push or manual dispatch, and completed successfully.
It checks the metadata against the run and allowed image repository and
verifies that the image digest exists in the registry.

It then opens a PR changing only the selected Application's:

* `spec.source.targetRevision` to the release's full source commit SHA.
* `app.image.imageRepo` and `app.image.imageDigest` Helm parameters.

The release combines the image with the Helm chart and configuration from
the tested commit. Promotion does not rebuild the image or merge the PR.

## Promotion Order and Approval

Promote Development first, then Staging, then Production. Staging requires
the same revision, repository and digest in Development's Application;
Production requires the same combination in Staging's Application.

These checks compare desired state in Git. They do not verify Argo CD sync
status, rollout health or live smoke tests. Check those before merging the
next environment's promotion PR.

Production promotion requires manually running the workflow and merging its
PR. Mandatory independent reviewer approval must be configured through GitHub
repository rules; workflow YAML alone does not enforce it. Protect workflow
and Argo CD control files as well, because direct edits can bypass promotion.

Each child Application is pinned to a commit. Root Applications follow main
to pick up merged Application changes, so editing chart templates on main
does not update every environment automatically.

## Rollback

1. Find the affected Application's last known-good release in Git history.
2. Open a PR restoring its revision, image repository and digest together.
3. Review and merge the PR; Argo CD synchronizes the restored release.
4. Verify sync status, rollout health and application behavior.

The normal promotion workflow enforces forward environment order. A rollback
PR restores a previous release directly and should receive the same review
as other production changes. Retain the referenced Git commits and Docker Hub
images; Git records release pointers even after CI artifacts expire.
