# oke-doke
![image](https://github.com/alam0rt/oke-doke/assets/35046326/c3020877-c81a-4f05-bf51-4b79eb63d11e)

Get a [free](https://www.oracle.com/au/cloud/free/), managed Kubernetes cluster with 3 arm64 worker nodes (1 vCPU & 8gb memory each)!

## Prerequisites

- [kind](https://kind.sigs.k8s.io/)
- [docker](doi://really?)
- [oci cli](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm)
- [clusterctl](https://cluster-api.sigs.k8s.io/clusterctl/overview.html)
- [capoci](https://oracle.github.io/cluster-api-provider-oci/)

## Instructions

- Grab the prereqs
- Set up an Oracle account & oci cli
- Copy `./env.example` to `./.env` and fill out the missing parts
- Run `./bootstrap.sh`
- Sit back and relax
