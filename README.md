# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

Development
feature-branch

Get Started
1. Just like in the warmup, plan out what data models you would need to allow users to be on the site (don’t worry about login/logout or securing the passwords right now), to submit links (“posts”), and to comment on links. Users do NOT need to be able to comment on comments… each comment refers to a Post.

2. Generate a new rails app from the command line ($ rails new micro-reddit) and open it up. We’ll use the default SQLite3 database so you shouldn’t have to change anything on that front.
```sh
Done!
```

3. Generate your User model and fill out the migration to get the columns you want.
Run the migration with $ rails db:migrate. You can use $ rails db:rollback if you realize you forgot anything or just create a new migration for the correction (which might involve the #add_column #remove_column or #change_column commands). See the Rails API Documentation for details on syntax and available methods.
```sh
rails generate model User username:string email:string password:string

Running via Spring preloader in process 2141
      invoke  active_record
      create    db/migrate/20191107154740_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create    test/models/user_test.rb
      create    test/fixtures/users.yml
```

Migrate DB;

```sh
rails db:migrate
/home/ggoh/.rbenv/versions/2.6.5/lib/ruby/gems/2.6.0/gems/railties-6.0.1/lib/rails/app_loader.rb:53: warning: Insecure world writable dir /mnt/c in PATH, mode 040777
== 20191107154740 CreateUsers: migrating ======================================
-- create_table(:users)
   -> 0.0036s
== 20191107154740 CreateUsers: migrated (0.0039s) =============================
```

Comfirm migration files was created in micro-reddit/db/migrate
```sh
class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :password

      t.timestamps
    end
  end
end
```

## Playing with Validations

1. In a new tab, open up the $ rails console. Try asking for all the users with > User.all. You should get back an empty array (no users yet!). Now create a blank new user and store it to a variable with > u = User.new. This user has been created in the ether of Ruby’s memory but hasn’t been saved to the database yet. Remember, if you’d used the #create method instead of the #new method, it would have just gone ahead and tried to save the new user right off the bat. Instead, we now get to play with it.
```sh
>> User.all
   (1.1ms)  SELECT sqlite_version(*)
  User Load (0.5ms)  SELECT "users".* FROM "users" LIMIT ?  [["LIMIT", 11]]
=> #<ActiveRecord::Relation []>
```

```sh
>> u = User.new
=> #<User id: nil, username: nil, email: nil, password: nil, created_at: nil, updated_at: nil>
````


2. Check whether your new user is actually valid (e.g. will it save if we tried?). > u.valid? will run all the validations. It comes up true… surprise! We haven’t written any validations so that’s to be expected. It’s also a problem because we don’t want to have users running around with blank usernames.
```sh
>> u.valid?
=> true
```

3. Implement the user validations you thought of in the first step in your app/models/user.rb file. These might involve constraints on the size of the username and that it must be present (otherwise you’ll potentially have users with no usernames!) and that it must be unique.
``` sh
#app/models/user.rb
class User < ApplicationRecord
	validates :username, presence :true,
	uniqueness: true, length: { maximum: 25 }
end
```

4. Reload your console using > reload!. You’ll need to do this every time you make changes to your app so the console can reload the current version. If it still seems broken, just > quit out of it and relaunch (sometimes #reload! doesn’t seem to do the trick). Build another new user but don’t save it yet by using > u2 = User.new. Run > u2.valid? again to run the validations and it should come up false. Good.
```sh
>> reload!
Reloading...
=> true
>>   u2 = User.new
   (0.1ms)  SELECT sqlite_version(*)
=> #<User id: nil, username: nil, email: nil, password: nil, created_at: nil, updated_at: nil>
>> u2.valid?
  User Exists? (0.5ms)  SELECT 1 AS one FROM "users" WHERE "users"."username" IS NULL LIMIT ?  [["LIMIT", 1]]
=> false
```


5. How do we find out what went wrong? Rails is helpful because it actually attaches error messages directly onto your user object when you fail validations so you can read into them with the #errors method. Try out > u2.errors to see the errors or, better, > u2.errors.full_messages to return a nice friendly array of messages. If you wrote custom messages into your validations, they will show up here as well.

```sh
>> u2.errors
=> #<ActiveModel::Errors:0x00007fffc5bbe7a8 @base=#<User id: nil, username: nil, email: nil, password: nil, created_at: nil, updated_at: nil>, @messages={:username=>["can't be blank"]}, @details={:username=>[{:error=>:blank}]}>
>> u2.errors.full_messages
=> ["Username can't be blank"]
```

6. Create a user who will actually save with > u3 = User.new(your_attributes_here) and run the validations. They should come up true. Save your user with the #save method so you’ve got your first user in the database.
```sh
>> u3 = User.new(username: "Odin", email: "odin@email.com", password: "buzzword")
=> #<User id: nil, username: "Odin", email: "odin@email.com", password: [FILTERED], created_at: nil, updated_at: nil>
>> u3.valid?
  User Exists? (0.3ms)  SELECT 1 AS one FROM "users" WHERE "users"."username" = ? LIMIT ?  [["username", "Odin"], ["LIMIT", 1]]
=> true
>> u3.save
   (0.1ms)  begin transaction
  User Exists? (0.3ms)  SELECT 1 AS one FROM "users" WHERE "users"."username" = ? LIMIT ?  [["username", "Odin"], ["LIMIT", 1]]
  User Create (2.7ms)  INSERT INTO "users" ("username", "email", "password", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["username", "Odin"], ["email", "odin@email.com"], ["password", "buzzword"], ["created_at", "2019-11-07 16:05:45.993186"], ["updated_at", "2019-11-07 16:05:45.993186"]]
   (3.4ms)  commit transaction
=> true
```

## Playing with Associations

1. Create your Post model by referencing your data plan from the first step above, migrate the database, and add its validations.
Migrate for the Post model and Post model validatios
```sh
class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end

class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 45 }
  validates :body, presence: true, length: { maximum: 200 }
end
```


2. Test your validations from the console, remembering to reload or relaunch it between changes.
```sh
irb(main):001:0> p = Post.new
   (0.3ms)  SELECT sqlite_version(*)
=> #<Post id: nil, title: nil, body: nil, created_at: nil, updated_at: nil>
irb(main):002:0> p.valid?
=> false
irb(main):003:0> p.title ='First Post'
=> "First Post"
irb(main):004:0> p.body = 'This is a greate day! ohrray'
=> "This is a greate day! ohrray"
irb(main):005:0> p.save
   (0.1ms)  begin transaction
  Post Create (0.2ms)  INSERT INTO "posts" ("title", "body", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["title", "First Post"], ["body", "This is a greate day! ohrray"], ["created_at", "2019-11-07 16:16:51.183041"], ["updated_at", "2019-11-07 16:16:51.183041"]]
   (130.8ms)  commit transaction
=> true
irb(main):006:0> p.valid?
=> true
```


3. Now set up your associations between User and Post models. Did you remember to include the foreign key column (user_id) in your posts table? If not, you can just add a new migration ($ rails generate migration yourmigrationname) and use the #add_column method mentioned above.

```sh
class AddForeingKeyToPost < ActiveRecord::Migration[6.0]
  def change
    add_reference :posts, :user, index: true
  end
end

class Post < ApplicationRecord
  ...
  belongs_to :user
end

class User < ApplicationRecord
  ...
	has_many :posts
end
```


4. If you’ve properly set up your associations, you should be able to use a few more methods in the console, including finding a User’s Posts and finding the Post’s User. First test finding your lonely User’s Posts – > User.first.posts. It should be an empty array since you haven’t created posts, but it shouldn’t throw an error at you.
```sh
irb(main):009:0> User.first.posts
  User Load (0.1ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT ?  [["LIMIT", 1]]
  Post Load (0.0ms)  SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = ? LIMIT ?  [["user_id", 1], ["LIMIT", 11]]
=> #<ActiveRecord::Associations::CollectionProxy []>

```


5. Build (but don’t yet save) a new post from the console, called p1, something like > p1 = Post.new(your_attributes_here). Don’t forget to include the ID of the user in your user_id field!.
```sh
irb(main):012:0> p1 = Post.new(title: "My New Post", body: "Something here in my post", user_id: 1)
=> #<Post id: nil, title: "My New Post", body: "Something here in my post", created_at: nil, updated_at: nil, user_id: 1>
```
6. Now build another post using the association to the user – substitute #new with #build and run through the association instead – p2 = User.first.posts.build. Don’t fill in any fields yet. Examine the object that was created and you’ll see that the ID field already got filled out for you, cool! This is a neat trick you’ll learn about in the lesson on associations.
```sh
irb(main):013:0> p2 = User.first.posts.build
  User Load (0.1ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT ?  [["LIMIT", 1]]
=> #<Post id: nil, title: nil, body: nil, created_at: nil, updated_at: nil, user_id: 1>
```
7 Save your original new post p1 so your user has officially written something. Test that you can use the other side of the association by trying > Post.first.user, which should return the original User object whose ID you pointed to when building the post. All has come full circle!
```sh
irb(main):014:0> p1.save
   (0.0ms)  begin transaction
  User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
  Post Create (0.1ms)  INSERT INTO "posts" ("title", "body", "created_at", "updated_at", "user_id") VALUES (?, ?, ?, ?, ?)  [["title", "My New Post"], ["body", "Something here in my post"], ["created_at", "2019-11-07 16:43:58.317303"], ["updated_at", "2019-11-07 16:43:58.317303"], ["user_id", 1]]
   (173.3ms)  commit transaction
=> true
irb(main):016:0> Post.all
  Post Load (0.1ms)  SELECT "posts".* FROM "posts" LIMIT ?  [["LIMIT", 11]]
=> #<ActiveRecord::Relation [#<Post id: 1, title: "First Post", body: "This is a greate day! ohrray", created_at: "2019-11-07 16:16:51", updated_at: "2019-11-07 16:16:51", user_id: nil>, #<Post id: 2, title: "My New Post", body: "Something here in my post", created_at: "2019-11-07 16:43:58", updated_at: "2019-11-07 16:43:58", user_id: 1>]>
irb(main):019:0> Post.second.user
  Post Load (0.2ms)  SELECT "posts".* FROM "posts" ORDER BY "posts"."id" ASC LIMIT ? OFFSET ?  [["LIMIT", 1], ["OFFSET", 1]]
  User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
=> #<User id: 1, username: "Odin", email: "odin@email.com", password: [FILTERED], created_at: "2019-11-07 16:31:12", updated_at: "2019-11-07 16:31:12">

```

### Add in Commenting

1. You’ve now got a User and a Post and they’ve been linked. Commenting will look quite similar to your Post model but will be related not just to the post who is its “parent” but also to the user who has authored it. Set up the migration and migrate the database for your Comment model.
```sh
rails generate model Comment body:text user:references post:references
Running via Spring preloader in process 2348
      invoke  active_record
      create    db/migrate/20191107170446_create_comments.rb
      create    app/models/comment.rb
      invoke    test_unit
      create      test/models/comment_test.rb
      create      test/fixtures/comments.yml
```

# db/migration
```sh
class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.text :body
      t.references :user, index: true
      t.references :post, index: true

      t.timestamps
    end
  end
end

db:migrate
== 20191107161121 CreatePosts: migrating ======================================
-- create_table(:posts)
   -> 0.0031s
== 20191107161121 CreatePosts: migrated (0.0050s) =============================

== 20191107162354 AddForeingKeyToPost: migrating ==============================
-- add_reference(:posts, :user, {:index=>true})
   -> 0.0073s
== 20191107162354 AddForeingKeyToPost: migrated (0.0094s) =====================

== 20191107170446 CreateComments: migrating ===================================
-- create_table(:comments)
   -> 0.0180s
== 20191107170446 CreateComments: migrated (0.0196s) ==========================
```

2. As before, add validations into your model and test them out in the console (refresh it!). Make sure you’ve required the two foreign keys (for posts and users) to be submitted, otherwise you could potentially have an orphan comment. You should not be able to save an invalid Comment and be able to save a valid Comment.
#app/models
```sh
class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
  ...
end
class User < ActiveRecord::Base
  ...
  has_many :posts
  has_many :comments
end
class Post < ActiveRecord::Base
  ...  
  belongs_to :user 
  has_many :comments
end
```

3. Build a second user and create a new comment which represents this user commenting on the first user’s post.
```sh
>> l = User.new(username: "Loki", email: "loki@email.com", password: "buzzword")
   (0.8ms)  SELECT sqlite_version(*)
=> #<User id: nil, username: "Loki", email: "loki@email.com", password: [FILTERED], created_at: nil, updated_at: nil>
>> l.valid?
  User Exists? (0.4ms)  SELECT 1 AS one FROM "users" WHERE "users"."username" = ? LIMIT ?  [["username", "Loki"], ["LIMIT", 1]]
=> true
>> l.save
   (0.1ms)  begin transaction
  User Exists? (0.2ms)  SELECT 1 AS one FROM "users" WHERE "users"."username" = ? LIMIT ?  [["username", "Loki"], ["LIMIT", 1]]
  User Create (8.5ms)  INSERT INTO "users" ("username", "email", "password", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["username", "Loki"], ["email", "loki@email.com"], ["password", "buzzword"], ["created_at", "2019-11-07 17:12:36.246522"], ["updated_at", "2019-11-07 17:12:36.246522"]]
   (2.9ms)  commit transaction
=> true

>> User.all
  User Load (0.4ms)  SELECT "users".* FROM "users" LIMIT ?  [["LIMIT", 11]]
=> #<ActiveRecord::Relation [#<User id: 1, username: "Odin", email: "odin@email.com", password: [FILTERED], created_at: "2019-11-07 16:05:45", updated_at: "2019-11-07 16:05:45">, #<User id: 2, username: "Loki", email: "loki@email.com", password: [FILTERED], created_at: "2019-11-07 17:12:36", updated_at: "2019-11-07 17:12:36">]>
```


4. As before, add the associations you need between users, posts, and comments. You’ll need to be able to do the following methods successfully from the console (assuming your second user has an ID of 2):

```sh
>> c = Comment.new("Nice post!")
Traceback (most recent call last):
        1: from (irb):8
ArgumentError (When assigning attributes, you must pass a hash as an argument, String passed.)
>> c = Comment.new(body: "Nice post!")
=> #<Comment id: nil, body: "Nice post!", user_id: nil, post_id: nil, created_at: nil, updated_at: nil>
>> c.save
=> false
>> c.errors.full_messages
=> ["User must exist", "User can't be blank", "Post must exist", "Post can't be blank"]
```

a. > u2 = User.find(2)
```sh
>> u = User.find(2)
  User Load (0.3ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 2], ["LIMIT", 1]]
=> #<User id: 2, username: "Loki", email: "loki@email.com", password: [FILTERED], created_at: "2019-11-07 17:12:36", updated_at: "2019-11-07 17:12:36">
```

b. > c1 = u2.comments.first should return that user’s comment. #comments returns an array with comments, which is why we need to use #first to actually retrieve the comment itself.
```sh
>> c = u.comments.first
  Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."user_id" = ? ORDER BY "comments"."id" ASC LIMIT ?  [["user_id", 2], ["LIMIT", 1]]
=> #<Comment id: 1, body: "I enjoyed your post!", user_id: 2, post_id: 1, created_at: "2019-11-07 17:27:42", updated_at: "2019-11-07 17:27:42">
```

c .> c1.user should return that comment’s author User (u2).
```sh
>> c.user
=> #<User id: 2, username: "Loki", email: "loki@email.com", password: [FILTERED], created_at: "2019-11-07 17:12:36", updated_at: "2019-11-07 17:12:36">
```

d .> p1 = Post.first
```sh
>> p1 = Post.first
  Post Load (0.3ms)  SELECT "posts".* FROM "posts" ORDER BY "posts"."id" ASC LIMIT ?  [["LIMIT", 1]]
=> #<Post id: 1, title: "My New Post", body: "Something here in my post", created_at: "2019-11-07 17:27:14", updated_at: "2019-11-07 17:27:14", user_id: 2>
```

e. > p1.comments.first should return the comment c1.
```sh
>> p1.comments.first
  Comment Load (0.6ms)  SELECT "comments".* FROM "comments" WHERE "comments"."post_id" = ? ORDER BY "comments"."id" ASC LIMIT ?  [["post_id", 1], ["LIMIT", 1]]
=> #<Comment id: 1, body: "I enjoyed your post!", user_id: 2, post_id: 1, created_at: "2019-11-07 17:27:42", updated_at: "2019-11-07 17:27:42">
```

f. > c1.post should return the post p1.
```sh
>> c.post
  Post Load (0.2ms)  SELECT "posts".* FROM "posts" WHERE "posts"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
=> #<Post id: 1, title: "My New Post", body: "Something here in my post", created_at: "2019-11-07 17:27:14", updated_at: "2019-11-07 17:27:14", user_id: 2>
``` 

If any of those don’t work, double check your associations. Sometimes the error messages can be helpful in prompting you for how to set up those associations.
