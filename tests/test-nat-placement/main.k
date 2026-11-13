import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

# Inline inputs keep the three operator-controlled cutover states independent
# of documentation examples. Unsorted layout AZs exercise the legacy fallback.
_cases: [any] = [
    {name = "default-layout", nat = {enabled = True}, created = ["a"], route = "a", manual = False, zones = ["c", "a", "b"], prior = "", natReady = False}
    {name = "return-to-default-with-cached-c", nat = {enabled = True}, created = ["a"], route = "a", manual = False, zones = ["a", "b", "c"], prior = "c", natReady = False}
    {name = "prepare-c", nat = {enabled = True, additionalAzSuffixes = ["c"]}, created = ["a", "c"], route = "a", manual = False, zones = ["a", "b", "c"], prior = "", natReady = False}
    {name = "cutover-retain-a", nat = {enabled = True, singleAzSuffix = "c", additionalAzSuffixes = ["a"]}, created = ["a", "c"], route = "c", manual = False, zones = ["a", "b", "c"], prior = "", natReady = False}
    {name = "wait-for-c-ready", nat = {enabled = True, singleAzSuffix = "c", additionalAzSuffixes = ["a"]}, created = ["a", "c"], route = "a", manual = False, zones = ["a", "b", "c"], prior = "a", natReady = False}
    {name = "switch-after-c-ready", nat = {enabled = True, singleAzSuffix = "c", additionalAzSuffixes = ["a"]}, created = ["a", "c"], route = "c", manual = False, zones = ["a", "b", "c"], prior = "a", natReady = True}
    {name = "keep-c-on-readiness-dip", nat = {enabled = True, singleAzSuffix = "c", additionalAzSuffixes = ["a"]}, created = ["a", "c"], route = "c", manual = False, zones = ["a", "b", "c"], prior = "c", natReady = False}
    {name = "selected-c", nat = {enabled = True, singleAzSuffix = "c"}, created = ["c"], route = "c", manual = False, zones = ["a", "b", "c"], prior = "", natReady = False}
    {name = "additional-active-c", nat = {enabled = True, singleAzSuffix = "c", additionalAzSuffixes = ["c"]}, created = ["c"], route = "c", manual = False, zones = ["a", "b", "c"], prior = "", natReady = False}
    {name = "manual-selected-c", nat = {enabled = True, singleAzSuffix = "c"}, created = ["c"], route = "c", manual = True, zones = ["b", "c"], prior = "", natReady = False}
    {name = "manual-prepare-c", nat = {enabled = True, additionalAzSuffixes = ["c"]}, created = ["b", "c"], route = "b", manual = True, zones = ["c", "b"], prior = "", natReady = False}
    {name = "ha-ignores-single-controls", nat = {enabled = True, strategy = "HighlyAvailable", singleAzSuffix = "z", additionalAzSuffixes = ["z"]}, created = ["a", "b", "c"], route = "by-zone", manual = False, zones = ["a", "b", "c"], prior = "", natReady = False}
]
_public_cidrs = {a = "10.42.0.0/24", b = "10.42.1.0/24", c = "10.42.2.0/24"}
_private_cidrs = {a = "10.42.16.0/20", b = "10.42.32.0/20", c = "10.42.48.0/20"}

items = [metav1alpha1.CompositionTest {
    metadata.name = "nat-placement-" + case.name
    spec = {
        compositionPath = "apis/networks/composition.yaml"
        xrdPath = "apis/networks/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Network"
            metadata = {name = "nat-placement", namespace = "default"}
            spec = {
                region = "us-east-2"
                vpc = {cidr = "10.42.0.0/16"}
                nat = case.nat
                if case.manual:
                    subnets = [{name = "nat-placement-public-" + az, availabilityZone = "us-east-2" + az, cidr = _public_cidrs[az], public = True} for az in case.zones] + [{name = "nat-placement-private-" + az, availabilityZone = az, cidr = _private_cidrs[az], public = False} for az in case.zones]
                else:
                    subnetLayout = {availabilityZones = case.zones}
            }
        }
        observedResources = [{
            apiVersion = "ec2.aws.m.upbound.io/v1beta1"
            kind = "VPC"
            metadata = {name = "nat-placement", namespace = "default", annotations = {"crossplane.io/composition-resource-name" = "vpc"}}
            status = {conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}], atProvider = {id = "vpc-test123", cidrBlock = "10.42.0.0/16"}}
        }] + ([{
            apiVersion = "ec2.aws.m.upbound.io/v1beta1"
            kind = "NATGateway"
            metadata = {name = "nat-placement-nat-c", namespace = "default", annotations = {"crossplane.io/composition-resource-name" = "nat-c"}}
            status = {conditions = [{type = "Ready", status = "True" if case.natReady else "False"}], atProvider = {id = "nat-test-c"}}
        }] + [{
            apiVersion = "ec2.aws.m.upbound.io/v1beta1"
            kind = "Route"
            metadata = {name = "nat-placement-rt-private-" + az + "-default-ipv4", namespace = "default", annotations = {"crossplane.io/composition-resource-name" = "route-rt-private-" + az + "-default-ipv4"}}
            spec.forProvider = {natGatewayId = "nat-cached-" + case.prior, natGatewayIdRef.name = "nat-placement-nat-" + case.prior}
        } for az in case.zones] if case.prior else [])
        assertResources = [{
            apiVersion = "ec2.aws.m.upbound.io/v1beta1"
            kind = "NATGateway"
            metadata.name = "nat-placement-nat-" + az
            spec.forProvider = {subnetIdRef.name = "nat-placement-public-" + az, allocationIdRef.name = "nat-placement-nat-eip-" + az}
        } for az in case.created] + [{
            apiVersion = "ec2.aws.m.upbound.io/v1beta1"
            kind = "Route"
            metadata.name = "nat-placement-rt-private-" + az + "-default-ipv4"
            spec.forProvider = {destinationCidrBlock = "0.0.0.0/0", routeTableIdRef.name = "nat-placement-private-rt-" + az, natGatewayIdRef.name = "nat-placement-nat-" + (az if case.route == "by-zone" else case.route)}
            spec.forProvider.natGatewayIdRef.policy.resolve = "Always"
        } for az in case.zones] + [{
            apiVersion = "ec2.aws.m.upbound.io/v1beta1"
            kind = "Subnet"
            metadata.name = "nat-placement-" + tier + "-" + az
            spec.forProvider.availabilityZone = "us-east-2" + az
        } for tier in ["public", "private"] for az in case.zones]
    }
} for case in _cases]
