# MongoidCacheStore

MongoidCacheStore helps in reducing the number of queries to the database.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid_cache_store'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid_cache_store

## Usage
For ex:
```ruby
class User
  include Mongoid::Document
  belongs_to :image, class_name: UserImage, inverse_of: nil
  # other user fields goes here
end

class UserImage
  include Mongoid::Document

  # image field goes here
end
```

Now, in order to display list of users on a listing page, we need data for users including their image url.
Accessing image method again & again will increase number of queries.

```ruby
cache_store = CacheStore.new.cache_docs(user_ids, User, [{field_name: 'image_id', klass: UserImage}])
user = cache_store.document(user_id, User)
user_image = cache_store.document(user.image_id, UserImage)
```

To fetch all documents of a particular klass cached.
```ruby
cache_store = CacheStore.new.cache_docs(user_ids, User, [{field_name: 'image_id', klass: UserImage}])
users = cache_store.sorted_documents(User)
```

To fetch list of documents for a list of ids ordered as per ids list.
```ruby
cache_store = CacheStore.new.cache_docs(user_ids, User, [{field_name: 'image_id', klass: UserImage}])
users = cache_store.sorted_documents(User, cusrom_user_ids)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mongoid_cache_store. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MongoidCacheStore project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mongoid_cache_store/blob/master/CODE_OF_CONDUCT.md).
