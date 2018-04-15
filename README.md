# UnobtrusiveResources

This gem provides convenient set of methods for resource management to keep your controllers as "skinny" as possible.
Main idea is to organize controller actions' code in terms of resource CRUD.

Example:

```ruby
class BotsController < ApplicationController
  # ...

  unobtrusive finder_method: :find_by_slug!,
              find_for_create_by: :slug,
              resource_class: Bot,
              relationship_name: :bots,
              permitted_params_key: :bot,
              permitted_params_create_value: %i[name code],
              permitted_params_update_value: %i[name code]
  def index
    respond_with(collection)
  end

  def show
    respond_with(resource)
  end

  def new
    build_resource
    respond_with(resource)
  end

  def create
    find_or_create_resource
    respond_with(resource)
  end

  def update
    update_resource
    respond_with(resource)
  end

  def destroy
    destroy_resource
    respond_with(resource)
  end
  # ...
end
```

Keep in mind, that following methods should be defined (or configured with `unobtrusive` method call) in order to make default configuration to work properly:

  - `relationship_name`
  - `resource_class`
  - `find_for_create_by`
  - `permitted_params_key`
  - `permitted_params_create_value`
  - `permitted_params_update_value`
  - `parent_class`
  - `parent_permitted_params_key`

For real-life projects most resource related actions will be a bit more complicated.
In such cases we can easily change underlying logic for, say, resource creation (redefine method):

```ruby
class BotsController < ApplicationController
  # ...

  private

  # Here `Bot` may be some model class or service object.
  def create_resource
    @_resource = Bot.custom_create(permitted_params)
  end
  # ...
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unobtrusive_resources'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unobtrusive_resources

## Usage

There is no need for additional initializer.
All necessary methods will be included into `ActionController::Base` via `ActiveSupport.on_load` (lazy load hook).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cimon-io/unobtrusive_resources. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the UnobtrusiveResources project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cimon-io/unobtrusive_resources/blob/master/CODE_OF_CONDUCT.md).
