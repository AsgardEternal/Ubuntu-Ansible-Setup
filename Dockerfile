# syntax=docker/dockerfile:1.4

# hadolint global ignore=DL3003,DL3008

FROM python:alpine as base

ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1

WORKDIR /app

FROM base as build

ENV PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

RUN pip install "poetry"

COPY pyproject.toml poetry.lock requirements.yml ./

RUN <<__EOR__
apk add --no-cache build-base
python -m pip install --upgrade pip
pip --version
poetry config virtualenvs.in-project true
poetry lock
poetry install --only=main,dev --no-root --no-ansi --no-interaction
poetry run ansible-galaxy install -r requirements.yml
__EOR__

FROM base as final

RUN <<__EOR__

apk add --no-cache \
    openssh-client \
    ca-certificates

__EOR__

COPY --from=build /app/.venv ./.venv
COPY . .
ENV PATH="${PATH}:/app/.venv/bin"

ENTRYPOINT [ "/bin/sh" ]
