SHELL := /bin/bash

PACKAGE ?= configuration-aws-network
XRD_DIR := apis/networks
COMPOSITION := $(XRD_DIR)/composition.yaml
DEFINITION := $(XRD_DIR)/definition.yaml
EXAMPLE_DEFAULT := examples/networks/example-minimal.yaml
EXAMPLES := $(wildcard examples/networks/*.yaml)
RENDER_TESTS := $(wildcard tests/test-*)
E2E_TESTS := $(wildcard tests/e2etest-*)

clean:
	rm -rf _output
	rm -rf .up

build:
	up project build

render: render-example

render-example:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) $(EXAMPLE_DEFAULT)

render-all:
	@for example in $(EXAMPLES); do \
		echo "Rendering $$example"; \
		up composition render --xrd=$(DEFINITION) $(COMPOSITION) $$example; \
	done

render-example-minimal:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-minimal.yaml

render-example-private-only:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-private-only.yaml

render-example-manual-cidr:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-manual-cidr.yaml

render-example-dual-stack:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-dual-stack.yaml

render-example-enterprise:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-enterprise.yaml

render-example-ipam-subnets:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-ipam-subnets.yaml

render-example-ipam-subnets-ondemand:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-ipam-subnets-ondemand.yaml

# Multi-step rendering for example-minimal
render-example-minimal-step-1:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-minimal.yaml \
		--observed-resources=examples/observed-resources/example-minimal/steps/1/

# Multi-step rendering for example-ipam-subnets
render-example-ipam-subnets-step-1:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-ipam-subnets.yaml \
		--observed-resources=examples/observed-resources/example-ipam-subnets/steps/1/

# Multi-step rendering for example-ipam-subnets-ondemand
render-example-ipam-subnets-ondemand-step-1:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-ipam-subnets-ondemand.yaml \
		--observed-resources=examples/observed-resources/example-ipam-subnets-ondemand/steps/1/

render-example-ipam-subnets-ondemand-step-2:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-ipam-subnets-ondemand.yaml \
		--observed-resources=examples/observed-resources/example-ipam-subnets-ondemand/steps/2/

render-example-ipam-subnets-ondemand-step-3:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-ipam-subnets-ondemand.yaml \
		--observed-resources=examples/observed-resources/example-ipam-subnets-ondemand/steps/3/

test:
	up test run $(RENDER_TESTS)

validate: validate-composition validate-examples

validate-composition:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) $(EXAMPLE_DEFAULT) --include-full-xr --quiet | crossplane beta validate $(XRD_DIR) --error-on-missing-schemas -

validate-examples:
	crossplane beta validate $(XRD_DIR) examples/networks

# Validation with observed resources for example-minimal
validate-example-minimal-step-1:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-minimal.yaml \
		--observed-resources=examples/observed-resources/example-minimal/steps/1/ \
		--include-full-xr --quiet | crossplane beta validate $(XRD_DIR) --error-on-missing-schemas -

# Validation with observed resources for example-ipam-subnets
validate-example-ipam-subnets:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-ipam-subnets.yaml \
		--include-full-xr --quiet | crossplane beta validate $(XRD_DIR) --error-on-missing-schemas -

validate-example-ipam-subnets-step-1:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-ipam-subnets.yaml \
		--observed-resources=examples/observed-resources/example-ipam-subnets/steps/1/ \
		--include-full-xr --quiet | crossplane beta validate $(XRD_DIR) --error-on-missing-schemas -

# Validation with observed resources for example-ipam-subnets-ondemand
validate-example-ipam-subnets-ondemand:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-ipam-subnets-ondemand.yaml \
		--include-full-xr --quiet | crossplane beta validate $(XRD_DIR) --error-on-missing-schemas -

validate-example-ipam-subnets-ondemand-step-1:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-ipam-subnets-ondemand.yaml \
		--observed-resources=examples/observed-resources/example-ipam-subnets-ondemand/steps/1/ \
		--include-full-xr --quiet | crossplane beta validate $(XRD_DIR) --error-on-missing-schemas -

validate-example-ipam-subnets-ondemand-step-2:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-ipam-subnets-ondemand.yaml \
		--observed-resources=examples/observed-resources/example-ipam-subnets-ondemand/steps/2/ \
		--include-full-xr --quiet | crossplane beta validate $(XRD_DIR) --error-on-missing-schemas -

validate-example-ipam-subnets-ondemand-step-3:
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) examples/networks/example-ipam-subnets-ondemand.yaml \
		--observed-resources=examples/observed-resources/example-ipam-subnets-ondemand/steps/3/ \
		--include-full-xr --quiet | crossplane beta validate $(XRD_DIR) --error-on-missing-schemas -

publish:
	@if [ -z "$(tag)" ]; then echo "Error: tag is not set. Usage: make publish tag=<version>"; exit 1; fi
	up project build --push --tag $(tag)

generate-definitions:
	up xrd generate $(EXAMPLE_DEFAULT)

e2e:
	up test run $(E2E_TESTS) --e2e
