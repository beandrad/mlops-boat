"""
Tasks for maintaining the project.

Execute 'invoke --list' for guidance on using Invoke.
Execute 'invoke <command> --help' for command details.
"""
from pathlib import Path

from environs import Env
from invoke import task
from invoke.context import Context

env = Env()
env.read_env()

ROOT_DIR = Path(__file__).parent
INFRA_DIR = ROOT_DIR.joinpath("infra")
LINE_LENGTH = 110


@task(
    help={
        "check": "Display if source is formatted without applying changes",
        "python": "Check python code",
        "tf": "Check terraform code",
    }
)
def fmt(runner, check=False, tf=True, python=True):  # type: ignore # pylint: disable=W0622
    """
    Format code
    """
    if python:
        # Run black
        check_option = "--check --diff" if check else ""
        black_options = f"{check_option} {ROOT_DIR}"
        command = f"black {black_options}"
        runner.run(command, pty=True)
        # Run isort
        check_option = "--check-only --diff" if check else ""
        isort_options = f"{check_option} {ROOT_DIR}"
        command = f"isort {isort_options}"
        runner.run(command, pty=True)
    if tf:
        check_option = "-check" if check else ""
        command = f"terraform fmt -recursive {check_option} {INFRA_DIR}"
        runner.run(command, pty=True)


@task
def lint(runner):  # type: ignore
    """
    Lint python code
    """
    command = f"mypy {ROOT_DIR}"
    runner.run(command, pty=True)

    command = f"pflake8 {ROOT_DIR}"
    runner.run(command, pty=True)

    command = f"pylint {ROOT_DIR}"
    runner.run(command, pty=True)


@task
def clean(runner):  # type: ignore
    """
    Clean up python/terraform file artifacts
    """
    for pattern in [
        ".mypy_cache",
        ".pytest_cache",
        "__pycache__",
        ".terraform",
        ".terraform.lock.hcl",
        "tfplan",
    ]:
        runner.run(f"find . -name {pattern} -exec rm -rf {{}} +", pty=True)


@task
def tf_init(runner):  # type: ignore # pylint: disable=unused-argument
    """
    Run tf init
    """
    ctx = Context()
    with ctx.cd("./infra"):
        ctx.run(
            f"""
            terraform init -upgrade \
                -backend-config=resource_group_name={env('TF_STATE_RESOURCE_GROUP_NAME')} \
                -backend-config=storage_account_name={env('TF_STATE_SA_NAME')} \
                -backend-config=key={env('ENVIRONMENT')}-update.tfstate \
                -backend-config=container_name={env('TF_STATE_CONTAINER_NAME')} -reconfigure"""
        )


@task
def tf_plan(runner):  # type: ignore # pylint: disable=unused-argument
    """
    Run tf plan
    """
    ctx = Context()
    with ctx.cd("./infra"):
        ctx.run(
            f"""terraform plan -input=false \
                -var-file="./config/{env('ENVIRONMENT')}.tfvars" -out=tfplan -parallelism=30"""
        )


@task
def tf_apply(runner):  # type: ignore # pylint: disable=unused-argument
    """
    Run tf apply
    """
    ctx = Context()
    with ctx.cd("./infra"):
        ctx.run("""terraform apply -auto-approve -parallelism=30 tfplan""")


@task
def tf_destroy(runner):  # type: ignore # pylint: disable=unused-argument
    """
    Run tf destroy
    """
    ctx = Context()
    with ctx.cd("./infra"):
        ctx.run(f"""terraform destroy -var-file="./config/{env('ENVIRONMENT')}.tfvars" """)
