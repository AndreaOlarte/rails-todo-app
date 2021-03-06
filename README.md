# TODO App on Rails
## MagmaHackers - Challenge 2

This challenge was set to be completed as a part of the MagmaHackers Program - 2018.

## Setting everything up
Install Rails and postgresql.

After that having that ready, we're gonna need to start a new Rails project.
On your command line let's run `rails new todo --skip-coffee --database=postgresql`
As you can see, we explicitly set the db as postgresql and we skip _coffee_ gem because we do not need it.

## Set log in
To enable different users to use the application, we should implement a log in. For that, we are gonna make use of _devise_, a gem that allows us to do that in a flexible, quick an easy way.

Add `gem 'devise'` to the Gemfile of your project and then make a `bundle install` to apply the new change.

Next step is to run `rails generate devise:install`.

After this, some instructions will show up, although for the required functionality, only adding `config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }` to the _config/environments/development.rb_ file will be necessary.

Don't forget to have the _postgresql_ server running before attempting the next step, so enter `sudo service postgresql start` in the command line to start it if you haven't.

Once you make sure server is on, let's type `rake db:setup` for the db iniatilization.
Some warnings are gonna show up because of the lack of the db schema file but that's normal, we're heading there.

To start the model for the devise feature run `rails generate devise User`.

Then, we are ready to migrate the db with `rake db:migrate` so the generated tables for the models are created.

You can try your project so far and checking everything's working with `rails s` to set the db up and the check our app on _localhost:3000_ to see the default home rails page, or _localhost:3000/users/sign_up_ to see the sign_up page generated by devise.

## Creating models
Next we need to create the models for the todo lists and the tasks, for that, we run: 
⋅⋅⋅**For creating List model:** `rails generate scaffold List title:string user_id:integer`, where _List_ is the model name and _title_ and _user_ are properties of the model (columns in the table).
⋅⋅⋅**For creating Task model:** `rails generate scaffold Task description:text done:boolean list_id:integer`.
And finally, we need to run `rails db:migrate` to update the schema with the new models.

Set the a method to allows users to go to the lists index once they sign in, at _app/controllers/application_controllers.rb_

``` ruby
def after_sign_in_path_for(resource)
  lists_path
end
```

Set `before_action :authenticate_user!` at the beginning of all the controllers so that noone can access those views unless they signed in

Add the corresponding relations among the models:
- `has_many :lists` in the _User_ model
+ `belongs_to :user` and `has_many :tasks` in the _List_ model
* `belongs_to :lists` in the _Task_ model

Change to `@lists = current_user.lists` in the _index_ action of the _lists_controller_ so that the lists brought on the index lists views are only the ones from the user signed in.

Change to `params.require(:list).permit(:title).merge(:user_id => current_user.id)` in the _lists_params_ action of the _lists_controller_.

Add `@tasks = @list.tasks` in the _show_ action of the _lists_controller_ so that the the tasks corresponding to that list are shown in the show view of the lists.

Update to this the _show view_ of the lists
``` html
<h1><%= @list.title %></h1>

<h2>Tasks</h2>

<table>
  <thead>
    <tr>
      <th>Desc</th>
      <th>Status</th>
      <th>TODO Lists</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @tasks.each do |task| %>
      <tr>
        <td><%= task.description %></td>
        <td><%= task.done %></td>
        <td><%= task.list_id %></td>
        <td><%= link_to 'Show', task %></td>
        <td><%= link_to 'Edit', edit_task_path(task) %></td>
        <td><%= link_to 'Destroy', task, method: :delete, data: { confirm: 'Are you sure?' } %></td>
      </tr>
    <% end %>
  </tbody>
</table>
<br>
<%= link_to 'New Task', new_task_path %>
<br>
```

## Features to consider for the layout
### Automatically taking list_id
When creating a new task, to link the list where the task is creating in so that the system sets the list_id automatically, it is only needed to replace the field for entering the list_id in the *views/tasks/_form.html.erb* file with
```ruby
<div class="field">
  <%= form.hidden_field :list_id, :value => params[:format] %>
</div>
```

And in change the link to a new task in the _lists/show_ view for `<%= link_to 'New Task', new_task_path(@list.id) %>`

Info from: https://apidock.com/rails/ActionView/Helpers/FormHelper/hidden_field and https://guides.rubyonrails.org/association_basics.html.

### New User attributes
Since the project required the user to have name and description attributes, besides the default ones generated by *Devise*, we need to add those extra columns for the User model. For that, first we need to run `rails generate migration AddDetailsToUsers name:string description:text`. For more info check this: https://guides.rubyonrails.org/active_record_migrations.html (editado)

And of course, after that, run `rake db:migrate`, so that the new changes are applied.

Now, add the following to both the *new* and *edit* *devise* or *users* views:
 ```ruby
<div class="field">
  <%= f.label :name %>
  <%= f.text_field :name, autofocus: true %>
</div>
...
<div class="field">
  <%= f.label :description %>
  <%= f.text_area :description %>
</div>
```

Then, add the keys `:name` and `:description` within the listed permitted parameters in the *application_controller* to leave it as shown:
```ruby
def configure_permitted_parameters
  devise_parameter_sanitizer.permit(:sign_up, keys: [:avatar, :name, :description])
  devise_parameter_sanitizer.permit(:account_update, keys: [:avatar, :name, :description])
end
```

Finally, you can try that this work by showing the new attributes in the layout. In my case, I added this to the items in my dropdown menu
```ruby
<p><%= current_user.name %></p>
<p><%= current_user.description %></p>
```

## Setting the image feature
Run `rails active_storage:install` and add this at the _config/environments/development.rb_

```ruby
# Store files locally.
config.active_storage.service = :local
``` 

Along with defining `has_one_attached :avatar` to the _User_ model

Run `rails generate devise:views` to have the geenerated views by Devise

At the _views/devise/registrations/new_ add
```html
<div class="field">
  <%= f.label :avatar %>
  <%= f.file_field :avatar %>
</div>
```

Add this to the _application_controller.rb_
```ruby
before_action :configure_permitted_parameters, if: :devise_controller?

protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar])
  end
```

Migrate the new generated tables from active storage: `rails db:migrate`

Add this to the view you want the image in
`<%= image_tag(currrent_user.avatar) %>`

### Resizing picture
Uncomment the Mini_Magick gem or add it in the gemfile `gem 'mini_magick', '~> 4.8'`
Then, run `bundle install`
After that I needed to install _imagemagick_ so the picture could be seen in the new size: `sudo apt install imagemagick-6.q16`, but if you don't have that problem, no need to do it.

Change the image to this: `<%= image_tag current_user.avatar.variant(resize: "500x500") %>`


For the CSV, really simple!: https://gorails.com/episodes/export-to-csv
Add `require 'csv'` before `require 'rails/all'` in _config_application.rb_

Add this in the _lists_controllers_ file, in the _show_ action


## Implementation of CSV Export
``` ruby
# CSV
  respond_to do |format|
    format.html
    format.csv { send_data @tasks.to_csv }
  end
```

And this in the _task_ model
```ruby
# CSV
  def self.to_csv
    attributes = %w{done description}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |task|
        csv << task.attributes.values_at(*attributes)
      end
    end
  end
```

Add `<%= link_to 'Export to CSV', {:format => :csv} %>` in the lists _show_ view to enable a link to perform the exportation and open/download the CSV file. 


## Implementation of PDF Generation
First, add `gem 'wicked_pdf'` and `gem 'wkhtmltopdf-binary'` to the *Gemfile* and then run `bundle install` to apply changes. After that run `rails g wicked_pdf`.

In *lists_controllers* add within the *show* action the following code:
``` ruby
respond_to do |format|
  format.html
  format.json
  format.pdf {render template: 'lists/pdf', pdf: 'pdfName'}
end
```

Go to *views/lists/* and add a new file which should be called _pdf.pdf.erb_ where in HTML we can write the information we want to be exported as pdf. As an option an stylesheet can be generated so that the content does not exceeds the size of the PDF:
``` css
tr{
  border-bottom: solid;
  border-width: 3px;
}
table, tr, td, th, tbody, thead, tfoot{
  page-break-inside: avoid !important;
}
```

Add the stylesheet in the HTML created: `<%= wicked_pdf_stylesheet_link_tag 'pdf' %>`


And finally add this to the HTML (do not forget to include the meta charset `<meta charset="utf-8">` so you can make use of most of the characters):
``` html
<% @list.tasks.each do |task| %>
  <tr>
    <td><%= task.desc %></td>
    <td><%= task.done %></td>
  </tr>
```


## Weekly email
### Setting mailers
First create a new Gmail account since it is necessary to leave the email and password in the development environment, so if you're gonna push your repo in github, make sure not to add your personal email account.

Generate a new mailer by running rails g mailer TodoMailer. This will create new files, so replace from@example.com with your newly created email address in the *app/mailers/application_mailer.rb* file.

Define the desired mailer method in the *app/mailers/todo_mailer.rb*, for example, in this case we are gonna add the following:
``` ruby
def weekly_reminder(user)
 @user = user
 mail(to: @user.email, subject: 'TODO App - Weekly Reminder')
end
```

Create a new view in the *views/todomailer/* folder to set the content for the body mail whether using and *.html.erb* or *.text.erb* structure (or both, preferably):

I created a file *views/todo_mailer/weekly_reminder.html.erb* with:
``` html
<h1>Here's your weekly reminder, <%= @user.name %></h1>
<p>Uncompleted tasks per TODO list</p>
<% @user.lists.each do |list| %>
  <h2>TODO List: <%= list.title %></h2>
  <ul>
  <% list.tasks.each do |task| %>
    <% unless task.done %>
    <li><%= task.description %></li>
    <% end %>
  <% end %>
  </ul>
<% end %>
<p>Don't give up on completing them and have a great day!</p>
```

And a file *views/todo_mailer/weekly_reminder.text.erb* with:
```
Here's your weekly reminder, <%= @user.name %>
===============================================
Uncompleted tasks per TODO list
<% @user.lists.each do |list| %>
TODO List: <%= list.title %>
  <% list.tasks.each do |task| %>
    <% unless task.done %>
    * <%= task.description %>
    <% end %>
  <% end %>
<% end %>

Don't give up on completing them and have a great day!
```

For the configurations of the email account and since I am going to be using a Gmail account, I set the following into *config/environments/development.rb*:
``` ruby
# Set the email account and configurations
config.action_mailer.delivery_method = :sendmail
# Defaults to:
# config.action_mailer.sendmail_settings = {
#  location: '/usr/sbin/sendmail',
#  arguments: '-i'
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = {from: 'youremail address@gmail.com'}

# Set email specifically for GMAIL account
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
address:       'smtp.gmail.com',
port:         587,
domain:        'example.com',
user_name:      'youremailsaddress@gmail.com', 
password:       'youremailpassword',
authentication:    'plain',
enable_starttls_auto: true }
```

Make sure to change the given email address and password for the ones you'll use. Also, you'll probably have already `config.action_mailer.raise_delivery_errors = false` so just delete that line.

Now it is only needed to call the mailer, but for that, it is needed to first, install Sidekiq and use a worker to have our weekly mails delivered.

### Sidekiq and Redis
We need to handle the action of sending emails through an background or asynchronous job. For that, it is needed to add to the Gemfile the following gems and run `bundle install`:
 ``` ruby
gem 'redis-rails'
gem 'sidekiq'
gem 'sidekiq-scheduler'
```

Make sure you have redis installed on your machine. If not, just run `sudo apt install redis` on your terminal.

Add `config.cache_store = :redis_store, "redis://localhost:6379/0/cache", { expires_in: 90.minutes }` in *config/application.rb* and in *routes.rb* add:
``` ruby
require 'sidekiq/web'
mount Sidekiq::Web => '/sidekiq'
```

To create our first background job, run `rails g sidekiq:worker YourWorkerName`. In my case, it was `rails g sidekiq:worker WeeklyReminder`

### Manage mailers in background job
Now, it is time to start integration both, the mailer and the background job together.
Go to the newly created file *app/workers/weekly_reminder_worker.rb* and in the *perform* action add the following code:
 ``` ruby
User.all.each do |user|
  unless(user.lists.length == 0)
    TodoMailer.weekly_reminder(user).deliver_now 
  end
end
```
This is the action to be performed by the background job, and it will go through all the users who have at least one TODO List and it will call the mailer created before to send that user a reminder email. 

To set some more configuration, it is necessary to create a new file *sidekiq.yml* into the *config/* folder and add:
``` yml
:concurrency: 25
:pidfile: ./tmp/pids/sidekiq.pid
:logfile: ./log/sidekiq.log
:queues:
 - default
 - mailers
:schedule:
  first:
    every: '1w'
    class: 'WeeklyReminderWorker'
```
In the *every* option we set the background job to perform what we indicated in the action every week.

Finally it is only needed to run `rails s` and in another terminal `redis-server`. To start the background job run `bundle exec sidekiq -C config/sidekiq.yml` in another terminal (the logs can be seen in the *sidekiq.log* file)
And done! We have a background job which is gonna send emails to the users with their uncompleted tasks.