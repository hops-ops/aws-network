### What's changed in v0.9.0

* chore(deps): update unbounded-tech/workflows-crossplane action to v2.20.0 (#19) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* chore(makefile): add generate-configuration target and fix shorthand (by @patrickleet)

  Wires hops validate generate-configuration as a prerequisite of
  validate:all / validate / validate:% so configuration.yaml is
  regenerated from upbound.yaml before each validation run.

  Also switches the render/validate shorthand aliases from
  `validate: validate\:all` (which fails "No rule to make target
  `validate\:all'") to the sub-make form `$(MAKE) 'validate:all'`.

  The `.gitignore` entry was auto-appended by the hops CLI on first
  run — configuration.yaml is a generated artifact.

  Implements [[tasks/update-xrd-makefiles-generate-config]]

* feat: support GUA and subnet IPAM allocation (#26) (by @patrickleet)

  * feat: support GUA and subnet IPAM allocation

  * feat: create VPC IPAM resource planning pools

  * feat: provision VPC CIDRs for IPAM subnet planning

  * fix: validate and document IPAM planning


See full diff: [v0.8.0...v0.9.0](https://github.com/hops-ops/aws-network/compare/v0.8.0...v0.9.0)
