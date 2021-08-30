# Paramore

Paramore allows you to declare a typed schema for your params,
so that any downstream code can work with the data it expects.

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

<h3>Without typing</h3>

```ruby
param_schema :item_params,
  item: [:name, :description, :for_sale, :price, metadata: [tags: []]]
```

This is completely equivalent (including the return type) to

```ruby
def item_params
  @item_params ||= params
    .require(:item)
    .permit(:name, :description, :for_sale, :price, metadata: [tags: []])
end
```

<h3>With typing</h3>

A common problem in app development is untrustworthy input given by clients.
That input needs to be sanitized and typecast for further processing.
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

class ItemsController < ApplicationController
  def create
    Item.create(item_params)
  end

  param_schema :item_params,
    item: {
      name: Paramore.field(Paramore::SanitizedString),
      description: Paramore.field(Paramore::StrippedString, null: true),
      for_sale: Paramore.field(Paramore::Boolean),
      price: Paramore.field(Paramore::Decimal),
      metadata: Paramore.field({
        tags: Paramore.field([Types::ItemTag], compact: true)
      })
    }
end
```

`Types::ItemTag` could be your own type:
```ruby
# app/types/item_tag.rb

module Types::ItemTag
  module_function
  def [](input)
    Item.tags[input.to_i]
  end
end
```

Now, given `params` are:
```ruby
<ActionController::Parameters {
  "unpermitted"=>"parameter",
  "name"=>"Shoe  \n",
  "description"=>"  Black,  with laces",
  "for_sale"=>"true",
  "price"=>"39.99",
  "metadata"=><ActionController::Parameters { "tags"=>["38", "112"] } permitted: false>
} permitted: false>
```
Calling `item_params` will return:
```ruby
<ActionController::Parameters {
  "name"=>"Shoe",
  "description"=>"Black,  with laces",
  "for_sale"=>true,
  "price"=>39.99,
  "metadata"=><ActionController::Parameters { "tags"=>[:shoe, :new] } permitted: true>
} permitted: true>
```

This is useful when the values are not used with Rails models, but are passed to simple functions for processing.
The types can also be easily reused anywhere in the app, since they are completely decoupled from Rails.

Notice that the `Paramore::StrippedString` does not perform `.squeeze(' ')`, only `Paramore::SanitizedString` does.

<h3>nil</h3>

Types are non-nullable by default and raise exceptions if the param hash misses any.
This can be disabled for any type by declaring `Paramore.field(Paramore::Int, null: true)`.

nils will usually not reach any of the type classes - if some parameter is nullable, the class will not be called.
If a parameter is non-nullable, then a `Paramore::NilParameter` error will be raised before calling the class.
If a, say, `item_ids` array is non-nullable, but the received parameter is `['1', '', '3']`, only the `'1'` and `'2'` will get passed to type classes, and the resulting array will contain a nil, eg.: `['1', nil, '3']`.
nils inside arrays can still be passed to type classes by declaring `Paramore.field([Paramore::Int], empty: true)`.
If you wish to get rid of empty array elements, declare `Paramore.field(Paramore::Int, compact: true)`.

<h3>Configuration</h3>

Running `$ paramore` will generate a configuration file located in `config/initializers/paramore.rb`.
- `config.type_method_name` - default is `[]`, to allow using, for example, `SuperString["foo"]` syntax. Note that changing this value will preclude you from using built in types.

<h3>Safety</h3>

  - Types will not be called if their parameter is missing (no key in the param hash)
  - All given types must respond to the configured `type_method_name` and an error will be raised when controllers are loaded if they don't.

# License

Paramore is released under the MIT license:

* https://opensource.org/licenses/MIT
