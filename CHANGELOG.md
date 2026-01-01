### What's changed in v0.1.0

* feat: initial commit (by @patrickleet)

* feat: subnets via ipam (by @patrickleet)

* fix: redundant naming (by @patrickleet)

* fix: enterprise validation (by @patrickleet)

* chore: pipeline updates (by @patrickleet)

* fix: unit tests (by @patrickleet)

* fix: clean up ipam selectors + e2e test (by @patrickleet)

* feat: private/public netmask + update e2e test to use private ipv6 (by @patrickleet)

* feat: crossplane v2 namespaced apiVersions + routes with relevant resources (by @patrickleet)

* feat: crossplane-contrib packages + renovate config + pipeline update (by @patrickleet)

* chore: pipeline versions (by @patrickleet)

* feat: ipam subnet pools (by @patrickleet)

* fix: ipv6 subnet pool definition (by @patrickleet)

* chore(deps): update unbounded-tech/workflows-crossplane action to v2.5.0 (#3) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* fix: region (by @patrickleet)

* fix: example / test cleanup (by @patrickleet)

* chore: example paths (by @patrickleet)

* chore(deps): update unbounded-tech/workflows-crossplane action to v2.5.1 (#4) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* chore: parallel tasks (by @patrickleet)

* chore(deps): update unbounded-tech/workflows-crossplane action to v2.6.0 (#6) (by @renovate[bot])

  * chore(deps): update unbounded-tech/workflows-crossplane action to v2.6.0

  * chore: Remove debug settings from on-pr workflow (auto-detected now)

  Removed debug configuration from the PR workflow.

  * chore: Remove debug settings from on-push-main

  Removed debug configuration from GitHub Actions workflow, those are now auto detected

  ---------

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>
  Co-authored-by: Patrick Lee Scott <pat@patscott.io>

* feat: integrate with ipam via values created by NetworkAllocation XRDs (#5) (by @patrickleet)

  * feat: cidr + allocations for subnets from ipam pools

  * fix: Removed unused $deletionPolicy variable + separate file for ipv4/6 cidr and allocations

  * feat: subnet pool

  * feat: move network allocation out of xrd to separate NetworkAllocation XRDs

* feat: subnets - without ipam for now (#7) (by @patrickleet)

  * feat: network allocations

  * feat: subnet allocations

  * feat: refactor values

  * fix: render / validate / e2e

  * fix: status refs

  * fix: e2e, locale, subnet size, readme

  * fix: refactor

  * chore: fix ipv6 pool

  * feat: vpc pool

  * fix: unused account id

  * chore: unit tests

  * feat: subnet pool from observed vpc pools

  * feat: subnet cidr math layout

  * fix: e2e test syntax

  * fix: ipv6 calc

  * fix:   Warning  CannotUpdateExternalResource  25s (x12 over 8m44s)  managed/ec2.aws.m.upbound.io/v1beta1, kind=subnet  (combined from similar events): async update failed: failed to update the resource: [{0 setting EC2 Subnet (subnet-0fa6b602ee98d3af5) AssignIpv6AddressOnCreation: operation error EC2: ModifySubnetAttribute, https response error StatusCode: 400, RequestID: 48efa9de-bb7c-4d7b-b708-2b0986692436, api error InvalidParameterValue: Invalid value true for assign-ipv6-address-on-creation. Cannot set assign-ipv6-address-on-creation to true unless the subnet (subnet-0fa6b602ee98d3af5) has an IPv6 CIDR block associated with it.  []}]

  * fix: missed file

  * fix: ipv6 calculation


