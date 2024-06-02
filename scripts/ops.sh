#!/bin/bash

DOCKER_USER=lianjiang549


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

function ee() {
    COMMAND=$*
    echo "Executing: $COMMAND"
    eval $COMMAND
}

function docker_build_push() {
    VERSION=$1
    if [ -z "$VERSION" ]; then
        echo "Usage: docker_build_push <version>"
        return
    fi
    # you can ask docker hub subscription from IT and
    # login docker account using docker dashboard. 
    IMAGE="$DOCKER_USER/neutrino:$VERSION"
    docker build -t $IMAGE .
    docker push $IMAGE
}

function k_bash() {
    CONTAINER_ID=$1
    if [ -z "$CONTAINER_ID" ]; then
        echo "Usage: docker_bash <container_id>"
        return
    fi
    ee k exec -it $CONTAINER_ID  -- /bin/sh
}

function k_create_image_pull_secret() {
    ACCESS_TOKEN=$1
    if [ -z "$ACCESS_TOKEN" ]; then
        echo "Usage: k_create_image_pull_secret access_token"
        return
    fi
    ee kubectl create secret docker-registry image-pull-secret --docker-server='https://index.docker.io/v1/' --docker-username="$DOCKER_USER" --docker-password="$ACCESS_TOKEN"
}

function hb_redeploy() {
    SIM=simulator.yaml
    if [ -n "$1" ]; then
        SIM=$1
    fi
    ee k delete -f $SIM
    ee k apply -f $SIM
    k get pod
}

function hb_demo() {
    ee hb_redeploy neutrino.yaml
    ee hb_redeploy worker.yaml
    ee hb_redeploy service.yaml
}

function k3d_create_cluster() {
    ee k3d cluster create mycluster -p 30629:30629@server:0  --volume /private/tmp:/private/tmp
}

function mongo_replica_start() {
    IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
    ee run-rs --host $IP
}
