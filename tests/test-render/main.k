import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_items = [
    # Test minimal network rendering (no NAT, dual-stack with Amazon IPv6)
    metav1alpha1.CompositionTest {
        metadata.name: "test-network-minimal"
        spec: {
            compositionPath: "apis/networks/composition.yaml"
            xrPath: "examples/networks/minimal.yaml"
            xrdPath: "apis/networks/definition.yaml"
            timeoutSeconds: 60
            validate: True
            assertResources: [
                # VPC should be created with IPAM pool selector and IPv6
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "VPC"
                    metadata: {
                        name: "my-vpc"
                    }
                    spec: {
                        forProvider: {
                            region: "us-east-1"
                            enableDnsHostnames: True
                            enableDnsSupport: True
                            assignGeneratedIpv6CidrBlock: True
                        }
                        providerConfigRef: {
                            kind: "ProviderConfig"
                            name: "my-cluster"
                        }
                    }
                }
                # Internet Gateway for public subnets
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "InternetGateway"
                    metadata: {
                        name: "my-vpc"
                    }
                }
                # Egress-only IGW for IPv6 private egress
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "EgressOnlyInternetGateway"
                    metadata: {
                        name: "my-vpc"
                    }
                }
                # Public route table
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "RouteTable"
                    metadata: {
                        name: "my-vpc-public"
                    }
                }
            ]
        }
    },
    # Test private-only network (no public subnets, no IGW, no NAT)
    metav1alpha1.CompositionTest {
        metadata.name: "test-network-private-only"
        spec: {
            compositionPath: "apis/networks/composition.yaml"
            xrPath: "examples/networks/private-only.yaml"
            xrdPath: "apis/networks/definition.yaml"
            timeoutSeconds: 60
            validate: True
            assertResources: [
                # VPC should be created
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "VPC"
                    metadata: {
                        name: "isolated-vpc"
                    }
                }
                # Private route tables should exist
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "RouteTable"
                    metadata: {
                        name: "isolated-vpc-private-rt-a"
                    }
                }
            ]
        }
    },
    # Test dual-stack network with NAT
    metav1alpha1.CompositionTest {
        metadata.name: "test-network-dual-stack"
        spec: {
            compositionPath: "apis/networks/composition.yaml"
            xrPath: "examples/networks/dual-stack.yaml"
            xrdPath: "apis/networks/definition.yaml"
            timeoutSeconds: 60
            validate: True
            assertResources: [
                # VPC with IPv6 enabled
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "VPC"
                    metadata: {
                        name: "ipv6-vpc"
                    }
                    spec: {
                        forProvider: {
                            assignGeneratedIpv6CidrBlock: True
                        }
                    }
                }
                # Egress-only IGW for IPv6 private egress
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "EgressOnlyInternetGateway"
                    metadata: {
                        name: "ipv6-vpc"
                    }
                }
                # NAT Gateway (SingleAz by default)
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "NATGateway"
                    metadata: {
                        name: "ipv6-vpc-nat-a"
                    }
                }
                # EIP for NAT
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "EIP"
                    metadata: {
                        name: "ipv6-vpc-nat-eip-a"
                    }
                }
            ]
        }
    },
    # Test manual CIDR network
    metav1alpha1.CompositionTest {
        metadata.name: "test-network-manual-cidr"
        spec: {
            compositionPath: "apis/networks/composition.yaml"
            xrPath: "examples/networks/manual-cidr.yaml"
            xrdPath: "apis/networks/definition.yaml"
            timeoutSeconds: 60
            validate: True
            assertResources: [
                # VPC with explicit CIDR block (no IPAM)
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "VPC"
                    metadata: {
                        name: "manual-vpc"
                    }
                    spec: {
                        forProvider: {
                            cidrBlock: "172.16.0.0/16"
                        }
                    }
                }
                # NAT Gateway should exist (SingleAz)
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "NATGateway"
                    metadata: {
                        name: "manual-vpc-nat-a"
                    }
                }
            ]
        }
    },
    # Test enterprise network with Transit Gateway and Flow Logs
    metav1alpha1.CompositionTest {
        metadata.name: "test-network-enterprise"
        spec: {
            compositionPath: "apis/networks/composition.yaml"
            xrPath: "examples/networks/enterprise.yaml"
            xrdPath: "apis/networks/definition.yaml"
            timeoutSeconds: 60
            validate: True
            assertResources: [
                # VPC
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "VPC"
                    metadata: {
                        name: "prod-vpc"
                    }
                }
                # Transit Gateway attachment
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "TransitGatewayVPCAttachment"
                    metadata: {
                        name: "prod-vpc-tgw-attachment"
                    }
                }
                # Flow logs
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "FlowLog"
                    metadata: {
                        name: "prod-vpc-flow-log"
                    }
                }
                # HA NAT (3 gateways for 3 AZs)
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "NATGateway"
                    metadata: {
                        name: "prod-vpc-nat-a"
                    }
                }
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "NATGateway"
                    metadata: {
                        name: "prod-vpc-nat-b"
                    }
                }
                {
                    apiVersion: "ec2.aws.m.upbound.io/v1beta1"
                    kind: "NATGateway"
                    metadata: {
                        name: "prod-vpc-nat-c"
                    }
                }
            ]
        }
    }
]

items = _items
