FROM python:3.13-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry
ENV POETRY_HOME="/opt/poetry"
ENV PATH="$POETRY_HOME/bin:$PATH"
RUN curl -sSL https://install.python-poetry.org | python3 -
RUN poetry config virtualenvs.in-project true

WORKDIR /app

# Copy only pyproject.toml and poetry.lock first (better caching)
COPY pyproject.toml poetry.lock* ./

RUN poetry install --only main --no-interaction --no-ansi --no-root

COPY src ./src

FROM python:3.13-slim AS runtime

# Create a non-root user
RUN useradd -m appuser

WORKDIR /app

COPY --from=builder /opt/poetry /opt/poetry
COPY --from=builder /root/.cache/pypoetry/ /root/.cache/pypoetry/
COPY --from=builder /app /app

ENV PATH="/opt/poetry/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

EXPOSE 8000

# Drop privileges
USER appuser

# Run FastAPI with Uvicorn (provided by fastapi[standard])
CMD ["poetry", "run", "fastapi", "run", "src/poetry_demo/main.py"]
