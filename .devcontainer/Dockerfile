ARG UBUNTU_VERSION="20.04"
FROM ubuntu:${UBUNTU_VERSION}

ARG PYTHON_VERSION=3.8
ARG TERRAFORM_VERSION=1.0.11
ARG TFLINT_VERSION=0.29.1
ARG POETRY_VERSION=1.1.11

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install git unzip vim \
    curl zsh gnupg2 iputils-ping jq software-properties-common \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Python
RUN add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get -y install python${PYTHON_VERSION} libpython${PYTHON_VERSION}-dev python3-pip python${PYTHON_VERSION}-dev python${PYTHON_VERSION}-venv gcc \
       build-essential libssl-dev libffi-dev python-dev libxml2-dev libxslt1-dev \
       libblas-dev libatlas-base-dev zlib1g-dev \
    && update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Install Poetry
ENV POETRY_HOME=/etc/poetry \
    POETRY_VIRTUALENVS_CREATE=false

RUN mkdir -p /tmp/docker-downloads \
    && curl -sSL -o /tmp/docker-downloads/install-poetry.py https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py \
    && python /tmp/docker-downloads/install-poetry.py --version ${POETRY_VERSION} \
    && chmod +x /etc/poetry/bin/poetry \
    && rm -rf /tmp/docker-downloads
ENV PATH=$PATH:/etc/poetry/bin:/etc/poetry/venv/bin

# Install Python dependencies
# COPY pyproject.toml pyproject.toml
# COPY poetry.lock poetry.lock
# RUN poetry install && rm pyproject.toml poetry.lock

# Install Terraform, tflint
RUN mkdir -p /tmp/docker-downloads \
    && curl -sSL -o /tmp/docker-downloads/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip /tmp/docker-downloads/terraform.zip \
    && mv terraform /usr/local/bin \
    && curl -sSL -o /tmp/docker-downloads/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_darwin_amd64.zip \
    && unzip /tmp/docker-downloads/tflint.zip \
    && mv tflint /usr/local/bin \
    && rm -rf /tmp/docker-downloads

# Install az cli - if fails, docker system prune --force
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install az cli ml extension
RUN az extension add -n ml -y

# Install dotnet-runtime - required for azureml datastore (https://github.com/microsoft/MLOpsPython/issues/295)
RUN curl -sSL -o packages-microsoft-prod.deb https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update && apt-get install -y --no-install-recommends dotnet-runtime-2.1

ARG DEBIAN_FRONTEND=interactive
