---
title: workareactl completion
body_class: body--nude
---
## workareactl completion

Generate completion script

### Synopsis

To load completions:

Bash:

$ source <(workareactl completion bash)

# To load completions for each session, execute once:
Linux:
	$ workareactl completion bash > /etc/bash_completion.d/workarea-cli
MacOS:
	$ workareactl completion bash > /usr/local/etc/bash_completion.d/workarea-cli

Zsh:

# If shell completion is not already enabled in your environment you will need
# to enable it.  You can execute the following once:

$ echo "autoload -U compinit; compinit" >> ~/.zshrc

# To load completions for each session, execute once:
$ workareactl completion zsh > "${fpath[1]}/_workarea-cli"

# You will need to start a new shell for this setup to take effect.

Fish:

$ workareactl completion fish | source

# To load completions for each session, execute once:
$ workareactl completion fish > ~/.config/fish/completions/workarea-cli.fish


```
workareactl completion [bash|zsh|fish|powershell]
```

### Options

```
  -h, --help   help for completion
```

### Options inherited from parent commands

```
      --clientID string   client to use
      --config string     config file (default is $HOME/.workareactl)
```

### SEE ALSO

* [workareactl](/cli/workareactl.html)	 - A tool for interacting with Workarea Commerce Cloud environments


