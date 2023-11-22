# 0.6.0

* Add support for Ruby 3.2
* Drop support for Ruby below 2.7

# 0.5.0

* Support and prefer `toml-rb` over `tomlrb` in the shipped TOML provider.
* Drop explicit support for Ruby < 2.4

# 0.4.0

* `Configurate::Proxy` returns its own singleton class if the target does not support creating one.
* Extract `Configurate::Provider::StringHash` as a new base class for hash based providers.
* Add `Configurate::Provider::TOML`.

# 0.3.1

* Configurate::Provider::Dynamic returns true when passed the special
 `reset_dynamic!` call.

# 0.3.0

* Add new exception: Configurate::MissingSetting to be raised and bubble up to the user
  if a setting wasn't found and the user requested to be informed.
* Configurate::Provider::YAML got the new option raise_on_missing to raise
  Configurate::MissingSetting if the requested key is not in the YAML document.

# 0.2.0

* Dynamic provider listens to reset_dynamic! message and forgets all settings on it.
* Calls ending in ! call the providers directly.
* Added SettingPath#action?, remove is_ prefix from SettingPath methods.
* Add implicit converters to Proxy that call the explicit converters.

# 0.1.0

* Dynamic provider resolves nested assignments

# 0.0.8

* Include README.md into the gem
* Skip namespace warning if there but empty
* Do not overwrite dup in SettingPath
* Fix tolerant loading of coveralls in the spec helper
* Improve comparisions in Proxy

# 0.0.7

* Only directly delegate methods returning meta-information in SettingPath
* Clean output of more methods in SettingPath
* Sanitize more input methods in SettingPath

# 0.0.6

* Use Forwardable instead of method_missing where possible
* Fix warning message on invalid namespace in YAML provider
* Refactor SettingPath to correctly handle special paths in way more places
* SettingPath#new now handles string paths, dropped SettingPath::from_string

# 0.0.4/0.0.5

* Pass duplicates of SettingPath into the provider so that it can be modified by it.
* Ensure SettingPath elements are strings

# 0.0.3

* Support Ruby 2.0.0
* Prefer `public_send` over `send`
* Manage setting paths through dedicated objects
* Pass new SettingPath objects directly into the providers
* Improve specs

# 0.0.2

* Return duplicates from the environment provider so that the return value can be modified by the client.

# 0.0.1

* Initial release
