#!/usr/bin/env bash

. .env

clusterctl init --infrastructure oci

kind create cluster capi || true
