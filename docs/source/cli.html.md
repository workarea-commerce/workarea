---
title: Hosting CLI Cheat Sheet
excerpt: This document will get you up and running with the Workarea Hosting CLI.
body_class: body--nude
---

# Workarea CLI Cheat Sheet

## Install the Workarea CLI

### Using an Apple Machine

Installation on macOS uses Homebrew. If you do not have Homebrew installed see <https://brew.sh/>

```bash
brew tap workarea/tools ssh://git@stash.tools.weblinc.com:7999/wl/homebrew-taps.git
brew cask install workarea-cli
```

Note that you need access to Workarea stash to install the CLI.

### Using a Linux Machine

To install Workarea CLI on linux run

```bash
wget --content-disposition https://packagecloud.io/weblinc/workarea-cli/packages/ubuntu/trusty/workarea-cli_2.1.0+20190424223847-1_amd64.deb/download.deb?read_token=632fa363936e9202ef857c752d851b1cc8d8cb4db166e515
```

## Setup Application

```bash
workarea setup --client-id={client_id} --aws-secret-access-key={key} --aws-access-key-id={key}
```

## Create a New Application or Plugin

To create a new application:

```bash
workarea new app {app_name}
```

To create a new plugin:

```bash
workarea new plugin {plugin_name}
```

## Doctor

### Detect new environments or fix connection issues with existing environments

```bash
workarea doctor -r
```

## Console

To open a rails console in an environment use:

```bash
workarea {env} console
```

## Debugging

### Check running pods

```bash
workarea {env} pods
```

### View Logs

#### App

```bash
workarea {env} logs app
```

You will be prompted to select pod and container.
Container choices are:

* app - look here for app startup issues
* app-log - look here for rails logs

This can be simplified by doing:

```bash
workarea {env} logs app -c app-log -f
```

Here you will be prompted to select a pod but we are specifying the container in the command (also note the `-f` to follow the logs)

#### Sidekiq

All the same notes from app apply!

```bash
workarea {env} logs sidekiq
```

#### Proxy

You only need to select the pod here.

```bash
workarea {env} logs proxy
```

### Getting a shell

```bash
workarea {env} bash app
```

Will be prompted to select a pod.  The "app" is optional, it will just filter the list of pods for you.

### Veryfying git commit of deploy

```bash
export KUBECONFIG=~/.weblinc/kubeconfigs/{client}-{cluster_env}-kubeconfig
kubectl -n {client}-{cluster_env}-app get deployments app -o jsonpath='{.spec.template.spec.containers[0].image}'
```

## Copy Files

To remote

```bash
workarea {env} cp --source=test.txt --destination=/workarea/test.txt --copy-to-remote
```

From remote

```bash
workarea {env} cp --source=test.txt --destination=test.txt
```

## Edit

You can edit secrets on your server with:

```bash
workarea {env} edit secrets
```

And edit proxy configuration with:

```bash
workarea {env} edit proxy
```

## Kibana

The Workarea CLI allows you to connect to your application's Kibana instance using port forwarding. This gives you access to the Kibana dev tools (including Elasticsearch console) and Logstash.

This feature is currently experimental and not available for all environments or applications, if you need access and the following command does not work, please contact Workarea support at <https://support.workarea.com>

```bash
workarea {env} fwd kibana 5601:5601
```
