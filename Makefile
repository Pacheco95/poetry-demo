.PHONY: $(MAKECMDGOALS)

FIND = find . -not -path "*/.venv/*"
RUN = poetry run

install:
	poetry install

clean:
	@rm -rf .coverage
	@rm -rf .pytest_cache
	@rm -rf dist
	@rm -rf .mypy_cache
	@$(FIND) -type d -name "__pycache__" -exec rm -rf {} +

run:
	$(RUN) fastapi run src/poetry_demo/main.py

run-dev:
	$(RUN) fastapi dev src/poetry_demo/main.py

test:
	$(RUN) pytest

coverage:
	$(RUN) pytest --cov=.

format:
	$(RUN) autopep8 --in-place --recursive .
	@echo

	$(RUN) isort .
	@echo

	$(RUN) black .

lint:
	$(RUN) flake8 .
	$(RUN) mypy .

docker-build:
	docker build -t poetry-demo .

docker-run: docker-build
	docker run --rm -p 8000:8000 poetry-demo:latest

docker-bash: docker-build
	docker run -it --user root --rm poetry-demo:latest /bin/bash
