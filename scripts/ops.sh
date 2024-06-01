#!/bin/bash

function create_argo_project() {
    argocd proj create hummingbird-jiangok ~/repo/hummingbird_jiangok/argocd/project.yml
    argocd proj list | grep hummingbird-jiangok
    argocd appset create ~/repo/hummingbird_jiangok/argocd/appset.yml
    argocd appset list | grep hummingbird-jiangok
}

function reinstall_hummingbird() {
    argocd app delete hummingbird-jiangok
    argocd appset delete hummingbird-jiangok
    argocd proj delete hummingbird-jiangok

    # create argo project
    argocd proj create hummingbird-jiangok ~/repo/hummingbird_jiangok/argocd/project.yml

    # configure argo project
    k apply -f ~/repo/hummingbird_jiangok/argocd/project.yml

    # confirm repositories are set.
    argocd proj get hummingbird-jiangok 
}