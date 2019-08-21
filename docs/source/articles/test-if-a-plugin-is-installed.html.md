---
title: Test if a Plugin is Installed
created_at: 2018/07/31
excerpt: It may be necessary to enable certain plugin functionality based on the presence of other plugins. The Workarea::Plugin.installed? method may be used to test if a plugin is installed.
---

# Test if a Plugin is Installed

It may be necessary to enable certain plugin functionality based on the presence of other plugins. The `Workarea::Plugin.installed?` method may be used to test if a plugin is installed.

```
Workarea::Plugin.installed?('Workarea::WishLists')
Workarea::Plugin.installed?('wish_lists')
Workarea::Plugin.installed?(:wish_lists)
```

For example, in the API plugin, you want to add functionality if the Wish Lists plugin is present.

```
if Workarea::Plugin.installed?(:wish_lists)
  module Workarea
    module Api
      module Users
        class WishListsController < Api::ApplicationController
          def show
            @user = User.find(params[:user_id])
            @wish_list = WishList.for_user(@user.id)
          end
        end
      end
    end
  end
end
```

