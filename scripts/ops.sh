#!/bin/bash

function create_argo_project() {
    argocd proj create hummingbird-jiangok ~/repo/hummingbird_jiangok/argocd/project.yml
    argocd proj list | grep hummingbird-jiangok
    argocd appset create ~/repo/hummingbird_jiangok/argocd/appset.yml
    argocd appset list | grep hummingbird-jiangok
}

