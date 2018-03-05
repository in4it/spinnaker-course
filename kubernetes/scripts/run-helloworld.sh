#!/bin/bash
kubectl run helloworld --image=k8s.gcr.io/echoserver:1.4 --port=8080
kubectl expose deployment helloworld --type=NodePort

