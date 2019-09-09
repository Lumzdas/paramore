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

<h3>Without formatting/sanitizing</h3>

```ruby
declare_params :item_params
  item: [:name, :description, :for_sale, :price, metadata: [tags: []]]
```

This is completely equivalent (including return type) to

```ruby
def item_params
  @item_params ||= params
    .require(:item)
    .permit(:name, :description, :for_sale, :price, metadata: [tags: []])
end
```

<h3>With formatting/sanitizing</h3>

A common problem in app development is untrustworthy input given by clients.
That input needs to be sanitized and potentially formatted and type-cast for further processing.
A naive approach could be:

```ruby
# items_controller.rb

def item_params
  @item_params ||= begin
    _params = params
      .require(:item)
      .permit(:name, :description, :for_sale, :price, metadata: [tags: []])

    _params[:name] = _params[:name].strip.squeeze(' ') if _params[:name]
    _params[:description] = _params[:description].strip.squeeze(' ') if _params[:description]
    _params[:for_sale] = _params[:for_sale].in?('t', 'true', '1') if _params[:for_sale]
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
  item: [:name, :description, :for_sale, :price, metadata: [tags: []]],
  format: {
    name: :Text,
    description: :Text,
    for_sale: :Boolean,
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
  def run(input)
    input.strip.squeeze(' ')
  end
end
```
```ruby
# app/formatter/boolean.rb

module Formatter::Boolean
  TRUTHY_TEXT_VALUES = %w[t true 1]

  module_function
  def run(input)
    input.in?(TRUTHY_TEXT_VALUES)
  end
end
```
```ruby
# app/formatter/decimal.rb

module Formatter::Decimal
  module_function
  def run(input)
    input.to_d
  end
end
```
```ruby
# app/formatter/item_tags.rb

module Formatter::ItemTags
  module_function
  def run(input)
    input.map { |tag_id| Item.tags[tag_id.to_i] }
  end
end
```


Now, given `params` are:
```ruby
<ActionController::Parameters {
  "unpermitted"=>"parameter",
  "name"=>"Shoe  \n",
  "description"=>"Black,  with laces",
  "for_sale"=>"true",
  "price"=>"39.99",
  "metadata"=><ActionController::Parameters { "tags"=>["38", "112"] } permitted: false>
} permitted: false>
```
Calling `item_params` will return:
```ruby
<ActionController::Parameters {
  "name"=>"Shoe",
  "description"=>"Black, with laces",
  "for_sale"=>true,
  "price"=>39.99,
  "metadata"=><ActionController::Parameters { "tags"=>[:shoe, :new] } permitted: true>
} permitted: true>
```

This is useful when the values are not used with Rails models, but are passed to simple functions for processing.
The formatters can also be easily reused anywhere in the app,
since they are completely decoupled from Rails.

<h3>Configuration</h3>

Running `$ paramore` will generate a configuration file located in `config/initializers/paramore.rb`.
- `config.formatter_namespace` - default is `Formatter`. Set to `nil` to have top level named formatters
  (this also allows specifying the formatter object itself, eg.: `name: Formatter::Text`).
- `config.formatter_method_name` - default is `run`. Don't set to `nil` :D

<h3>Safety</h3>

  - Formatters will not be called if their parameter is missing (no key in the param hash)
  - Formatters are validated - all given formatter names must match actual modules/classes defined in the app
    and must respond to the configured `formatter_method_name`.
    This means that all used formatters are loaded when the controller is loaded.

# License

Paramore is released under the MIT license:

* https://opensource.org/licenses/MIT
