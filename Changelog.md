# 0.0.4/0.0.5

## Bug fixes

* Pass duplicates of SettingPath into the provider so that it can be modified by it.
* Ensure SettingPath elements are strings

# 0.0.3

## Refactor

* Support Ruby 2.0.0
* Prefer `public_send` over `send`
* Manage setting paths through dedicated objects
* Pass new SettingPath objects directly into the providers
* Improve specs

# 0.0.2

## Bug fixes

* Return duplicates from the environment provider so that the return value can be modified by the client.

# 0.0.1

* Initial release
