SHELL := /bin/bash

PACKAGE ?= aws-network
XRD_DIR := apis/networks
COMPOSITION := $(XRD_DIR)/composition.yaml
DEFINITION := $(XRD_DIR)/definition.yaml
CONFIGURATION := $(XRD_DIR)/configuration.yaml
EXAMPLE_DEFAULT := examples/networks/minimal.yaml
RENDER_TESTS := $(wildcard tests/test-*)
E2E_TESTS := $(wildcard tests/e2etest-*)

# Examples list - mirrors GitHub Actions workflow
# Format: example_path::observed_resources_path (observed_resources_path is optional)
# with-ipam is tested at all 4 steps to validate multi-step reconciliation
EXAMPLES := \
    examples/networks/minimal.yaml:: \
    examples/networks/standard.yaml:: \
    examples/networks/dual-stack-ula.yaml:: \
    examples/networks/dual-stack-amazon.yaml:: \
    examples/networks/high-availability.yaml:: \
    examples/networks/import-example.yaml:: \
    examples/networks/with-ipam.yaml::examples/test/mocks/observed-resources/with-ipam/steps/1 \
    examples/networks/with-ipam.yaml::examples/test/mocks/observed-resources/with-ipam/steps/2 \
    examples/networks/with-ipam.yaml::examples/test/mocks/observed-resources/with-ipam/steps/3 \
    examples/networks/with-ipam.yaml::examples/test/mocks/observed-resources/with-ipam/steps/4

clean:
	rm -rf _output
	rm -rf .up
	rm -f $(CONFIGURATION)

build:
	up project build

generate-configuration:
	@set -euo pipefail; \
	hops validate generate-configuration --path . --api-path "$(XRD_DIR)"

# Render all examples (parallel execution, output shown per-job when complete)
render\:all:
	@tmpdir=$$(mktemp -d); \
	pids=""; \
	for entry in $(EXAMPLES); do \
		example=$${entry%%::*}; \
		observed=$${entry#*::}; \
		outfile="$$tmpdir/$$(echo $$entry | tr '/:' '__')"; \
		( \
			set -o pipefail; \
			if [ -n "$$observed" ]; then \
				echo "=== Rendering $$example with observed-resources $$observed ==="; \
				up composition render --xrd=$(DEFINITION) $(COMPOSITION) $$example --observed-resources=$$observed; \
			else \
				echo "=== Rendering $$example ==="; \
				up composition render --xrd=$(DEFINITION) $(COMPOSITION) $$example; \
			fi; \
			echo "" \
		) > "$$outfile" 2>&1 & \
		pids="$$pids $$!:$$outfile"; \
	done; \
	failed=0; \
	for pair in $$pids; do \
		pid=$${pair%%:*}; \
		outfile=$${pair#*:}; \
		if ! wait $$pid; then failed=1; fi; \
		cat "$$outfile"; \
	done; \
	rm -rf "$$tmpdir"; \
	exit $$failed

# Validate all examples (parallel execution, output shown per-job when complete)
validate\:all: generate-configuration
	@tmpdir=$$(mktemp -d); \
	pids=""; \
	for entry in $(EXAMPLES); do \
		example=$${entry%%::*}; \
		observed=$${entry#*::}; \
		outfile="$$tmpdir/$$(echo $$entry | tr '/:' '__')"; \
		( \
			set -o pipefail; \
			if [ -n "$$observed" ]; then \
				echo "=== Validating $$example with observed-resources $$observed ==="; \
				up composition render --xrd=$(DEFINITION) $(COMPOSITION) $$example \
					--observed-resources=$$observed --include-full-xr --quiet | \
					crossplane resource validate $(XRD_DIR) --error-on-missing-schemas -; \
			else \
				echo "=== Validating $$example ==="; \
				up composition render --xrd=$(DEFINITION) $(COMPOSITION) $$example \
					--include-full-xr --quiet | \
					crossplane resource validate $(XRD_DIR) --error-on-missing-schemas -; \
			fi; \
			echo "" \
		) > "$$outfile" 2>&1 & \
		pids="$$pids $$!:$$outfile"; \
	done; \
	failed=0; \
	for pair in $$pids; do \
		pid=$${pair%%:*}; \
		outfile=$${pair#*:}; \
		if ! wait $$pid; then failed=1; fi; \
		cat "$$outfile"; \
	done; \
	rm -rf "$$tmpdir"; \
	exit $$failed

# Shorthand aliases
.PHONY: render validate generate-configuration
render: ; @$(MAKE) 'render:all'
validate: ; @$(MAKE) generate-configuration 'validate:all'

# Single example render (usage: make render:minimal)
render\:%:
	@example="examples/networks/$*.yaml"; \
	if [ -f "$$example" ]; then \
		echo "=== Rendering $$example ==="; \
		up composition render --xrd=$(DEFINITION) $(COMPOSITION) $$example; \
	else \
		echo "Example $$example not found"; \
		exit 1; \
	fi

# Single example validate (usage: make validate:minimal)
validate\:%: generate-configuration
	@example="examples/networks/$*.yaml"; \
	if [ -f "$$example" ]; then \
		echo "=== Validating $$example ==="; \
		set -o pipefail; \
		up composition render --xrd=$(DEFINITION) $(COMPOSITION) $$example \
			--include-full-xr --quiet | \
			crossplane resource validate $(XRD_DIR) --error-on-missing-schemas -; \
	else \
		echo "Example $$example not found"; \
		exit 1; \
	fi

test:
	up test run $(RENDER_TESTS)

e2e:
	up test run $(E2E_TESTS) --e2e

publish:
	@if [ -z "$(tag)" ]; then echo "Error: tag is not set. Usage: make publish tag=<version>"; exit 1; fi
	up project build --push --tag $(tag)

generate-definitions:
	up xrd generate $(EXAMPLE_DEFAULT)

generate-function:
	up function generate --language=go-templating render $(COMPOSITION)
