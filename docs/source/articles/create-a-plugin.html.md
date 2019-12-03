---
title: Create a Plugin
created_at: 2018/09/17
excerpt: To create a Workarea plugin, use the rails plugin new command with a Workarea plugin template.
---

# Create a Plugin

To create a Workarea plugin, use the _rails plugin new_ command with a Workarea plugin template.

```bash
rails plugin new path/to/my_plugin \
  --template=https://raw.githubusercontent.com/workarea-commerce/workarea/master/plugin_template.rb \
  --full \
  --skip-spring \
  --skip-active-record \
  --skip-action-cable \
  --skip-puma \
  --skip-coffee \
  --skip-turbolinks \
  --skip-bootsnap \
  --skip-yarn \
  --skip-webpack-install
```

This template can be found in the [workarea repository](https://github.com/workarea-commerce/workarea) at [https://github.com/workarea-commerce/workarea/blob/master/plugin_template.rb](https://github.com/workarea-commerce/workarea/blob/master/plugin_template.rb).

After creating the plugin, edit the gemspec file to set relevant plugin meta data.

Plugins may be developed within their own git repository or as part of an existing repository, such as a host application built on the Workarea platform. If developing the plugin within an existing repository, be sure to change the `s.files` logic within the gemspec to include only files relevant to the plugin. For example, `Dir.glob` over a given array of directory globs rather than including all files with `git ls-files`.
