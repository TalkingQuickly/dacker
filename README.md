# Dacker

Dacker is a Docker orchestration tool written in Ruby. It works across multiple hosts and is designed to be used for managing both development and production environments.

Please note that Dacker is very new and currently under heavy development and so use in production is very much at your own risk.

## Usage

### Rails Example

This example assumes a Rails application using Postgres as a database but should be generally applicable to web applications. Vagrant is required for local development so make sure you've got an up to date version installed before starting <https://www.vagrantup.com/downloads.html>.

Begin by adding the dacker gem to your Gemfile and running bundle.

In the root of the project execute `bundle exec dacker install`. This will generate a simple example configuration, including a `Vagrantfile` for local development.

Bring up the Vagrant node with `vagrant up`. This a lightweight VM running only the Docker daemon. You will be prompted for your sudo password, this is required to setup NFS shares which offer far better performance the Vagrant defaults.

Ensure the `pg` gem is present in your Gemfile and then modify your `config/database.yml` to source credentials from the environment as follows:

```yaml
default: &default
  adapter: postgresql
  pool: 5
  timeout: 5000
  host: <%= ENV['PG_HOST'] %>
  username: <%= ENV['PG_USERNAME'] %>
  password: <%= ENV['PG_PASSWORD'] %>

development:
  <<: *default
  database: application_name_development

test:
  <<: *default
  database: application_name_test

production:
  <<: *default
  database: application_name_production
```

Execute `bundle exec dacker deploy` and wait. The first time you run this it may take a while as it has to download several images and build the Rails app image from scratch. Subsequent usage will be much faster.

Visit 192.168.50.60 in your browser. If all's well you will see your Rails app!

The default configuration mounts the root of the project in `/vagrant` which is in turn mounted in /app of the `rails_app` docker container. This means that changes made locally in development will be reflected immediately as per usual, without needing to re-deploy.

#### Executing Commands in the Rails Environment

Dacker provides a simple interface for running commands within your applications containers.

To execute a command in the `rails_app` container, as defined in the `Dackerfile`, use:

```bash
bundle exec dacker execute rails_app "SOMECOMMAND"
```

For example to create your database:

```bash
bundle exec dacker execute rails_app "rake db:create"
```

And to start a Rails console:

```bash
bundle exec dacker execute rails_app "rails console"
```

You can even start a standard shell with:

```bash
bundle exec dacker execute rails_app "bash"
```

Remember though, each of these commands runs in an entirely isolated environment, so no files are persisted. The exception to this is files written to `/app` in development since this is a shared folder on your local filesystem (the project root).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/dacker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
