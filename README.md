# Configurate - A flexible configuration system
[![Gem Version](https://badge.fury.io/rb/configurate.svg)](https://badge.fury.io/rb/configurate)
[![Build Status](https://travis-ci.org/jhass/configurate.svg?branch=master)](https://travis-ci.org/jhass/configurate)
[![Code Climate](https://codeclimate.com/github/jhass/configurate.svg)](https://codeclimate.com/github/jhass/configurate)
[![Coverage Status](https://coveralls.io/repos/jhass/configurate/badge.svg?branch=master)](https://coveralls.io/r/jhass/configurate?branch=master)

Configurate allows you to specify a chain of configuration providers which are
queried in order until one returns a value. This allows scenarios like overriding
your default settings with a user configuration file and let those be overridden
by environment variables. The query interface allows to group and nest your configuration options
to a practically unlimited level.

Configurate supports Ruby 2.0 or later.

## Installation

Just add

```ruby
gem 'configurate'
```

to your `Gemfile`.


## Usage

A basic loader could look like this:

```ruby
require 'configurate'

Config = Configurate::Settings.create do
  add_provider Configurate::Provider::Env
  add_provider Configurate::Provider::YAML, '/etc/app_settings.yml',
               namespace: Rails.env, required: false
  add_provider Configurate::Provider::YAML, 'config/default_settings.yml'
end

# Somewhere later
if Config.remote_assets.enable?
  set_asset_host Config.remote_assets.host
end
```

You can add custom methods working with your settings to your `Configurate::Settings` instance
by calling `extend YourConfigurationMethods` inside the block passed to `#create`.

Providers are called in the order they're added. You can already use the added providers to
determine if further ones should be added:

```ruby
require 'configurate'

Config = Configurate::Settings.create do
  add_provider Configurate::Provider::Env
  add_provider Configurate::Provider::YAML, 'config/settings.yml' unless heroku?
end
```

`add_provider` can be called later on the created object to add more providers to the chain.
It takes a constant and parameters that should be passed to the initializer.

A providers only requirement is that it responds to the `#lookup` method. `#lookup` is passed the current
`SettingPath`, for example for a call to `Config.foo.bar.baz?` it gets a path with the items `'foo'`, `'bar'`, `'baz'` passed. `SettingPath` behaves like `Array` with some methods added.
The provider should raise `Configurate::SettingNotFoundError` if it can't provide a value for the requested option.
Any additional parameters are passed along to the provider, thus a `#lookup` method must be able to take
any number of additional parameters.

You're not limited to one instance of the configuration object.

## Gotchas

### False

Ruby does not allow to metaprogram `false`, thus something like

```ruby
puts "yep" if Config.enable_stuff
```

always outputs `yep`. The workaround is to append `.get`, or `?` to get the
real value:

```ruby
puts "yep" if Config.enable_stuff?
```

### Module#===

Another thing you can't overwrite in Ruby is the `===` operator, rendering case statements useless

```ruby
puts case Config.some.setting
     when NilClass
       "nil"
     when String
       "string"
     else
       "unknown"
     end
```

will always output `unknown`. Again use `.get`


## Shipped providers

### Configurate::Provider::Env

This class transforms a query string into a name for a environment variable and looks up this variable then.
The conversion scheme is the following: Convert to uppercase, join path with underscores. So for example `Config.foo.bar.baz`
would look for a environment variable named `FOO_BAR_BAZ`. Additionally it splits comma separated values
into arrays.

This provider does not take any additional initialization parameters.

### Configurate::Provider::TOML

This provider reads settings from a given [TOML](https://github.com/toml-lang/toml) file. It converts the sections of
query string to a nested value. For a given TOML file

```toml
[stuff]
enable = true
param = "foo"

[stuff.nested]
param = "bar"
```

the following queries would be valid:

```ruby
Config.stuff.enable?      # => true
Config.stuff.param        # => "foo"
Config.stuff.nested.param # => "bar"
```

This provider depends on the [tomlrb](https://github.com/fbernier/tomlrb) gem. This is why it is not loaded by default and
needs an explicit `require 'configurate/provider/toml' to be available.

The initializer takes a path to the configuration file a the mandatory first argument and
the following optional parameters:

* *namespace:* Specify a alternative root. This is useful if you for example add the same file multiple
  times through multiple providers, with different namespaces, letting you override settings depending on
  the rails environment, without duplicating common settings. Defaults to none.
* *required:* Whether to raise an error if the the file isn't found or, if one is given, the namespace
  doesn't exist in the file.

### Configurate::Provider::YAML

This provider reads settings from a given [YAML](http://www.yaml.org) file. It converts the sections of
query string to a nested value. For a given YAML file

```yaml
stuff:
  enable: true
  param: "foo"
  nested:
    param: "bar"
```

the following queries would be valid:

```ruby
Config.stuff.enable?      # => true
Config.stuff.param        # => "foo"
Config.stuff.nested.param # => "bar"
```

The initializer takes a path to the configuration file a the mandatory first argument and
the following optional parameters:

* *namespace:* Specify a alternative root. This is useful if you for example add the same file multiple
  times through multiple providers, with different namespaces, letting you override settings depending on
  the rails environment, without duplicating common settings. Defaults to none.
* *required:* Whether to raise an error if the the file isn't found or, if one is given, the namespace
  doesn't exist in the file.


### Configurate::Provider::StringHash

A provider taking a (nested) `Hash` where all keys are strings. The query string is then looked up in this hash.

So for a given `Hash`

```ruby
{
  "stuff" => {
    "enable" => true,
    "param" => "foo",
    "nested" => {
      "param" => "bar"
    }
  }
}
```

the following queries would be valid:

```ruby
Config.stuff.enable?      # => true
Config.stuff.param        # => "foo"
Config.stuff.nested.param # => "bar"
```

The initializer takes the hash as the mandatory first argument and
the following optional parameters:

* *namespace:* Specify a alternative root. This is useful if you for example add the same file multiple
  times through multiple providers, with different namespaces, letting you override settings depending on
  the rails environment, without duplicating common settings. Defaults to none.
* *required:* Whether to raise an error if the namespace
  doesn't exist in the hash.
* *source:* A hint text about the origin of the configuration data to be used in error messages.

As you may have noticed by now, `Configurate::Provider::YAML` and `Configurate::Provider::TOML` are merely convenience
subclasses of this provider, loading the file for you.

### Configurate::Provider::Dynamic

A provider which stores the first additional parameter if the query string ends with an equal sign and can
return it later. This is mainly useful for testing but can be useful to temporarily override stuff too. To clarify a small example:

```ruby
Config.foo.bar         # => nil
Config.foo.bar = "baz"
Config.foo.bar         # => "baz"
Config.reset_dynamic!
Config.foo.bar         # => nil
```

### Configurate::Provider::Base

A convenience base class changing the interface for implementers. It provides a basic `#lookup` method
which just passes all parameters through to `#lookup_path`.
The result of `#lookup_path` is returned, unless it's `nil`
then `Configurate::SettingNotFoundError` is raised. Subclasses are expected to implement `#lookup_path`.
Do not use this class directly as a provider!

## Writing a provider

...should be pretty easy. For example here is the `Configurate::Provider::Env` provider:

```ruby
class Configurate::Provider::Env < Configurate::Provider::Base
  def lookup_path(setting_path, *args)
    value = ENV[setting_path.join("_").upcase]
    unless value.nil?
      value = value.dup
      value = value.split(",") if value.include?(",")
    end
    value
  end
end
```

`Configurate::Provider::StringHash` should also serve as a useful baseclass for most providers.


## Documentation

You can find the current documentation for the master branch [here](http://rubydoc.info/github/jhass/configurate/master/frames/index).


## License

MIT, see [LICENSE](./LICENSE)
