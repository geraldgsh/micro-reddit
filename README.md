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
