# Dacker

Dacker is a Docker orchestration tool written in Ruby. It works across multiple hosts and is designed to be used for managing both development and production environments.

## Dacker v Compose

On the surface Dacker has a lot in common with [Compose](http://docs.docker.com/compose/). It allows you to orchestrate containers based on a yaml file definition. In practice the primary purpose of Dacker was to allow us to orchestrate containers directly from a Rails application by passing around standard Ruby hashes. YAML file deployment was a welcome bonus since YAML files are easily loaded into standard Ruby hashes.

If you just need YAML file container orchestration, you're almost certainly better off using Compose as it has far broader functionality. If you're looking to directly orchestrate containers from Ruby code, Dacker may be useful to you.

## Why Dacker Exists

Dacker began as an internal tool at [Make It With Code](http://www.makeitwithcode.com). Specifically we needed to deploy a NodeJS application in a container, whenever a user signed up to the Rails application. The Rails application needed to manage this deployment. When an existing user logged in, we needed to be able to check if their container was running and if not re-start it.

We built Dacker because the above meant we had several requirements, not met by existing orchestration tools:

* An easy way to embed container lifecycle management into a Rails application and reason in terms of "container state" rather than specific Docker API calls
* A single toolchain for both development environments and production deployments
* Full support for deploying to multiple hosts without a requirement to publicly expose the Docker Daemons HTTP API
* An easy method of managing production infrastructure without requiring any additional server side daemons or central orchestration servers
* Very quick deployment of "standard" Ruby (Rails or Sinatra) applications and associated stacks which could co-exist and scale across a shared pseudo cluster of standard nodes

## Example Usage (Rails)

This example assumes a Rails application using Postgres as a database but should be generally applicable to web applications. Vagrant is required for local development so make sure you've got an up to date version installed before starting <https://www.vagrantup.com/downloads.html>.

Begin by adding the `dacker` gem to your `Gemfile` and running `bundle`.

In the root of the project execute `bundle exec dacker install`. This will generate a simple example configuration, including a `Vagrantfile` for local development.

The most important file here is the `Dackerfile.yml` which uses a [Fig](www.fig.sh) like syntax for defining containers and environments.

The default Rails Dackerfile looks like this:

```yaml
vagrant: &VAGRANT
  host: 192.168.50.60
  user: vagrant
  password: vagrant

development:
  rails_app:
    build: .
    ports:
     - "3000:3000"
    environment:
     - RAILS_ENV=development
     - PG_HOST=192.168.50.60
     - PG_USERNAME=postgres
    volumes:
     - /vagrant:/app
    deploy:
     name: web1
     signal: SIGTERM
     container:
      - delete
      - build
      - create
      - start
     order: 2
     <<: *VAGRANT

  load_balancer:
    image: nginx
    volumes:
     - /home/vagrant/vhosts:/etc/nginx/conf.d
    ports:
     - "80:80"
    deploy:
     name: lb1
     files:
      - /home/vagrant/vhosts/test_app.conf:dacker/templates/vhost
     signal: HUP
     order: 1
     <<: *VAGRANT

  database:
    image: postgres
    volumes:
     - /home/vagrant/pg_data:/var/lib/postgresql/data
    ports:
     - 5432:5432
    deploy:
     name: pg1
     order: 0
     <<: *VAGRANT
```

This defines three containers for our environment, an Nginx load balancer, a rails application and a postgresql database server. It also defines the volumes for these containers for persistence and the ports to be exposed. If the idea of data volumes and exposing ports is new to you don't worry, just head over to [the interactive docker tutorial](https://www.docker.com/tryit/) then come back here!

Notice that this is a standard YAML file, so you can use anchors and aliases in exactly the same way they're used in something like the Rails `database.yml`.

Bring up the Vagrant node with `vagrant up`. This a lightweight VM running only the Docker daemon. You will be prompted for your sudo password, this is required to setup NFS shares which offer far better performance than the Vagrant defaults.

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

Note that we set these environment variables in the `environment` section of the `rails_app` container in the `Dackerfile`.

Execute `bundle exec dacker deploy` and wait. The first time you run this it may take a while as it has to download several images and build the Rails app image from scratch. Subsequent usage will be much faster.

Visit 192.168.50.60 in your browser. If all's well you will see your Rails app!

The default configuration mounts the root of the project in `/vagrant` which is in turn mounted in /app of the `rails_app` docker container. This means that changes made locally in development will be reflected immediately as per usual, without needing to re-deploy.

## Executing Commands in the Rails Environment

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

## Known Issues

When building the container from a local Dockerfile after doing `dacker deploy`, you'll sometimes see an error like: `error getting container from driver devicemapper`. This appears to be due to some sort of race condition when unmounting/ mounting. Generally just re-running the deploy will resolve it, it's currently unclear exactly why this occurs.

## Specs

Requires a live Docker host to run against (eventually this will use VCR). The Docker API should be accessible on localhost, port 5000. The easiest way is to fire up a suitable Vagrant box and then establish an SSH tunnel, e.g. `ssh -L 5000:127.0.0.1:2375 -N deploy@192.168.50.31`. This host should have the `ubuntu` base image already pulled (e.g. `docker pull ubuntu`).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/dacker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
