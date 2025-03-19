FORMAT_DIR = src

release_from-develop:
	gh pr create --base main --head develop --title "Release v$(version)"
	gh pr merge --auto
	gh release create $(version) --target main --latest --generate-notes --title "$(version)"

build:
	rm -rf dist
	pip install -e .[build]
	python -m build

release:
	echo "Releasing version $(version)"
	make format
	make lint
	git add .
	git commit -m 'release: $(version)' --allow-empty
	git push origin develop
	make release_from-develop version=$(version)

commit:
	make format
	git add .
	git commit -m '$(message)'

format:
	pip install -e .[format]
	ruff format $(FORMAT_DIR)

lint:
	pip install -e .[lint]
	ruff check $(FORMAT_DIR) --fix
	python -m mypy $(FORMAT_DIR) --install-types --non-interactive

PHONY: build release release_from-develop format commit