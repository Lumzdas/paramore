# Paramore

Paramore is a small gem intended to make strong parameter definitions declarative
and provide a unified way to format and sanitize their values outside of controllers.

# Installation


In your Gemfile:
```ruby
gem 'paramore'
```

In your terminal:
```sh
$ bundle
```

# Usage

<h3>Simple</h3>

```ruby
declare_params :item_params
  item: [:name, :description, :price, metadata: [tags: []]]
```

This is completely equivalent (including return type) to

```ruby
def item_params
  @item_params ||= params
    .require(:item)
    .permit(:name, :description, :price, metadata: [tags: []])
end
```

<h3>Extended</h3>

A common problem in app development is untrustworthy input given by clients.
That input needs to be sanitized and potentially formatted and type-cast for further processing.
A naive approach could be:

```ruby
# items_controller.rb

def item_params
  @item_params ||= begin
    _params = params
      .require(:item)
      .permit(:name, :description, :price, metadata: [tags: []])

    _params[:name] = _params[:name].strip.squeeze(' ') if _params[:name]
    _params[:description] = _params[:description].strip.squeeze(' ') if _params[:description]
    _params[:price] = _params[:price].to_d if _params[:price]
    if _params.dig(:metadata, :tags)
      _params[:metadata][:tags] =
        _params[:metadata][:tags].map { |tag_id| Item.tags[tag_id.to_i] }
    end

    _params
  end
end
```

This approach clutters controllers with procedures to clean data, which leads to repetition and difficulties refactoring.
The next logical step is extracting those procedures - this is where Paramore steps in:

```ruby
# app/controllers/items_controller.rb

declare_params :item_params
  item: [:name, :description, :price, metadata: [tags: []]],
  format: {
    name: :Text,
    description: :Text,
    price: :Decimal,
    metadata: {
      tags: :ItemTags
    }
  }
```

```ruby
# app/formatter/text.rb

module Formatter::Text
  module_function
  def run(text)
    text.strip.squeeze(' ')
  end
end
```
```ruby
# app/formatter/decimal.rb

module Formatter::Decimal
  module_function
  def run(string)
    string.to_d
  end
end
```
```ruby
# app/formatter/item_tags.rb

module Formatter::ItemTags
  module_function
  def run(array)
    array.map { |tag_id| Item.tags[tag_id.to_i] }
  end
end
```

Paramore does not limit you to its own API - calling `item_params` will return an instance of
`ActionController::Parameters` with all of the declared parameters permitted and formatted (where applicable).

Formatters are modules/classes, which are recognized by a naming convention: `Formatter::<custom_name>`
and must respond to `#run`, taking just one argument - the parameter.

<h3>Safety</h3>

  - Formatters will not be called if their parameter is missing (no key in the param hash)
  - Formatters are validated - all given formatter names must match actual modules/classes defined in the app
    and must respond to the configured `formatter_method_name`.
    This means that all used formatters are loaded when the controller is loaded.

<h3>Configuration</h3>

Running `$ paramore` will generate a configuration file located in `config/initializers/paramore.rb`.
- `config.formatter_namespace` - default is `Formatter`. Set to `nil` to have top level named formatters.
- `config.formatter_method_name` - default is `run`. Don't set to `nil` :D

# License

Paramore is released under the MIT license:

* https://opensource.org/licenses/MIT
