# =============================================================================
# freedomcode sandbox — Dockerfile
# Python 3.12 execution environment for AI-generated code
# =============================================================================
FROM python:3.12-slim-bookworm

LABEL maintainer="freedomcode"
LABEL description="Isolated Python sandbox for safe AI code execution"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip && pip install \
    numpy scipy pandas matplotlib sympy \
    jupyterlab ipykernel ipywidgets \
    requests httpx \
    pytest black ruff \
    rich typer

RUN useradd -m -s /bin/bash sandbox && \
    mkdir -p /workspace && \
    chown sandbox:sandbox /workspace

WORKDIR /workspace

USER sandbox

CMD ["/bin/bash"]
