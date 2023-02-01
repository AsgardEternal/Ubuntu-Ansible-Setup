# syntax=docker/dockerfile:1.4

# hadolint global ignore=DL3003,DL3008

FROM python:3.11-alpine3.17 as base

ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1

WORKDIR /app

FROM base as build

ENV PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    POETRY_VERSION=1.3.2

RUN pip install "poetry==$POETRY_VERSION"

COPY pyproject.toml poetry.lock ./

RUN <<__EOR__
poetry config virtualenvs.in-project true
poetry install --only=main,dev --no-root --no-ansi --no-interaction
__EOR__

FROM base as final

RUN <<__EOR__

apk add --no-cache \
    openssh-client=9.1_p1-r1 \
    ca-certificates=20220614-r4

__EOR__

COPY --from=build /app/.venv ./.venv
COPY . .
ENV PATH="${PATH}:/app/.venv/bin"

RUN <<__EOR__
ansible-galaxy install -r requirements.yml
__EOR__

ENTRYPOINT [ "/bin/sh" ]
