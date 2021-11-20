# MLOPS Boat

This project contains the code to provision a secure MLOPS environment in Azure following the architecture documented in the [Azure documentation](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/ai-machine-learning-enterprise-security#recommended-network-security-architecture).

## Getting started

1. Setup dev environment. 
There are two options: start the devcontainer, which contains all the dependencies needed, or setup the development environment manually (see [Section: Setup dev environment](#setup-dev-environment-manually)).

2. Make a copy of `.env.template` and set the values.
```bash
cp .env.template .env
```

3. Check the project management commands.
This project uses the Python library [invoke](https://www.pyinvoke.org/) for project management (which is similar to using GNU Make). The tasks are defined in the [tasks.py](tasks.py) file. To display the commands available execute `invoke --list`.

Before being able to execute any of the Terraform commands, make sure you log in to Azure using az cli or setup the service principal `ARM_*` environment variables (see [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret) for details).

## Setup dev environment manually

Install pre-requisites:

- Python3.8 (the Azureml Python SDK is not compatible with newer Python versions).
- Poetry (Python package manager).
- Terraform v1.0 or above.

Create Python virtual environment, install dependencies and activate virtual environment:
```bash
poetry install
source `poetry env info --path`/bin/activate
```

## Dependency management

Poetry is in charge of the dependency management in this project. Direct dependencies are defined in `pyproject.toml` (along with other project configuration - such as the linting config and description); the `poetry.lock` contains all the dependencies and their versions.

To add a new dependency, execute `poetry add <package name>="<version>"`; in general, you just want to use the latest stable version and for that you use "*" as `version` (the actual version installed is pinned in the poetry.lock and won't be upgraded unless `poetry update` is executed).

You can also indicate that a dependency should be only installed in `dev` (for instance, the linters - mypy or flake8), for that add the `--dev` parameter: `poetry add --dev <package name>="<version>"`.

When running `poetry install`, if a `poetry.lock` exists in the project, the packages pinned to the versions in that file will be installed.

## Issues

This section describes future work and blockers/issues that need to be solved.

- Enable App Insights. The connection to App Insights should be private; for that we need to deploy an [Azure Monitor Private Link Scope](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/private-link-security), not available in the Terraform provider yet (see [issue#10059](https://github.com/hashicorp/terraform-provider-azurerm/issues/10059)).
