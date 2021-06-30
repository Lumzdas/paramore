# Paramore

Paramore is a small gem intended to make strong parameter definitions declarative
and provide a unified way to typecast and sanitize their values outside of controllers.

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
paramorize :item_params,
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

  paramorize :item_params,
    item: {
      name: Paratype[Paramore::SanitizedString],
      description: Paratype[Paramore::StrippedString],
      for_sale: Paratype[Paramore::Boolean],
      price: Paratype[Paramore::Decimal],
      metadata: Paratype[{
        tags: Paratype[[Types::ItemTag]]
      }]
    }
end
```

`Types::ItemTags` could be your own type:
```ruby
# app/types/item_tags.rb

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

<h3>nil<h3>

No nil will ever reach any of the type classes - if some parameter is nullable, the class will not be called.
If a parameter is non-nullable, then a `Paramore::NilParameterError` will be raised before calling the class.
If a, say `item_ids` array is non-nullable, but the received parameter is `['1', nil, '3']`, only the `'1'`
and `'2'` will get passed to type classes, and the resulting array will contain the nil.

<h3>Configuration</h3>

Running `$ paramore` will generate a configuration file located in `config/initializers/paramore.rb`.
- `config.type_method_name` - default is `[]`, to allow using, for example, `SuperString["foo"]` syntax.

<h3>Safety</h3>

  - Types will not be called if their parameter is missing (no key in the param hash)
  - All given types must respond to the configured `type_method_name` and an error will be raised
    if they don't when controllers are loaded.

# License

Paramore is released under the MIT license:

* https://opensource.org/licenses/MIT
