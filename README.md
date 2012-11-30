# Configurate - A flexible configuration system

Docs are TODO. Just one gotcha if you want to use it straight away:

Ruby does not allow to metaprogram `false`, thus something like

```ruby
puts "yep" if Config.enable_stuff
```

always outputs `yep`. The workaround is to append `.get` or `?` to get the
real value:

```ruby
puts "yep" if Config.enable_stuff?
```
