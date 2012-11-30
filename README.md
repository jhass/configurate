# Configurate - A flexible configuration system
[![Build Status](https://secure.travis-ci.org/MrZYX/configurate.png?branch=master)](https://travis-ci.org/MrZYX/configurate)
[![Gemnasium](https://gemnasium.com/MrZYX/configurate.png)](https://gemnasium.com/MrZYX/configurate)

Docs and Readme are WIP. Just one gotcha if you want to use it straight away:

Ruby does not allow to metaprogram `false`, thus something like

```ruby
puts "yep" if Config.enable_stuff
```

always outputs `yep`. The workaround is to append `.get` or `?` to get the
real value:

```ruby
puts "yep" if Config.enable_stuff?
```

Meanwhile checkout the [docs](http://rubydoc.info/github/MrZYX/configurate/master/frames/index).
