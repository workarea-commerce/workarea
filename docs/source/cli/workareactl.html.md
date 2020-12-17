---
title: workareactl
body_class: body--nude
---
## workareactl

A tool for interacting with Workarea Commerce Cloud environments

## Installation

`workareactl` can be installed via Homebrew on macOS and linux. If you do not have Homebrew installed see <https://brew.sh/>

```bash
brew tap workarea/tools https://stash.tools.weblinc.com/scm/wl/homebrew-taps.git
brew install workareactl
```

### Options

```
      --clientID string   client to use
      --config string     config file (default is $HOME/.workareactl)
  -h, --help              help for workareactl
```

### SEE ALSO

* [workareactl bash](/cli/workareactl-bash.html)	 - Open a bash shell on a pod
* [workareactl completion](/cli/workareactl-completion.html)	 - Generate completion script
* [workareactl console](/cli/workareactl-console.html)	 - Open a rails console on an app pod
* [workareactl cp](/cli/workareactl-cp.html)	 - Copy file
* [workareactl creds](/cli/workareactl-creds.html)	 - Creds uses SSO to get temporary AWS credentials to use
* [workareactl delete-job](/cli/workareactl-delete-job.html)	 - Cleanup all pods created by job (e.g. Rake, Runner, Execute)
* [workareactl edit](/cli/workareactl-edit.html)	 - Edit various aspects of the environment
* [workareactl logs](/cli/workareactl-logs.html)	 - Print pod logs
* [workareactl pods](/cli/workareactl-pods.html)	 - Lists pods
* [workareactl port-forward](/cli/workareactl-port-forward.html)	 - Forward a port from an pod in this environment
* [workareactl rake](/cli/workareactl-rake.html)	 - Execute a rake task on a pod
* [workareactl release](/cli/workareactl-release.html)	 - Builds a docker image for the environment and updates the deployments
* [workareactl rollback](/cli/workareactl-rollback.html)	 - Rollback to previous deployment
* [workareactl status](/cli/workareactl-status.html)	 - Display the environment status
* [workareactl token](/cli/workareactl-token.html)	 - Token uses SSO to get a bearer token to authenticate with the k8s cluster
* [workareactl update-kubeconfig](/cli/workareactl-update-kubeconfig.html)	 - Updates kubeconfig with current cluster, context and user
* [workareactl version](/cli/workareactl-version.html)	 - Print workareactl version


