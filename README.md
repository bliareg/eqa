# Standalone version development

## Requirements:
 - Ubuntu 16.04 or newer (for server)
 - Docker 1.13.0 or newer (for container running machine)
 - Ansible 2.2.1.0

### Commands for setup [Guard::RSpec](https://github.com/guard/guard-rspec) and [Spring](https://github.com/rails/spring)
```sh
bundle exec guard init rspec
bundle binstub guard
bundle exec spring binstub --all
```
run
```sh
guard
```
for launch specs when files are modified.
