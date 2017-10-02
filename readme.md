---
title: Layouts, Partials, and Views
type: lesson
duration: "1:25"
creator:
    name: Gerry Mathe
    city: London
competencies: Server Applications
---

# Layouts, Partials, and Views

### Objectives
*After this lesson, students will be able to:*

- Describe how templates & views work together
- Use partials for static content and rendering dynamic content

### Preparation
*Before this lesson, students should be able to:*

- Write HTML
- Describe how to yield a template in a layout
- Use Ruby instance variables in templates
- Use params to store data in instance variables

## Views in Rails - Intro (10 mins)

In this lesson we will cover the details of rendering views and best practices for keeping the views DRY.

When the app is created, Rails will by default add a layout `application.html.erb` in `app/views/layouts/application.html.erb`. This layout already contains a `<%yield%>` statement ( that "injects" the template rendered for the current route) and all the links to css and js files in the head part of the html document. Combined, the templates and layouts will be sent back to the client.

## Using views with Rails - Demo (20 mins)

In Rails, the logic for the rendering a view is quite straightforward. Given that every route in Rails will execute a method inside a controller, when the method is executed, Rails will look for:

1. A folder inside `views` corresponding to the controller's name (folder `dinos` for `DinosController`).
2. A file with the method's name and `.html.erb`.

For example , if we call `http://localhost:3000/dinos`, Rails will execute the method `index` in the controller `dinos` and then look for a template located in `app/views/dinos/index.html.erb`  This works when the method always renders the same template.

In some cases though, you may want to render a template with a different name than the current method. Let's take a look at this action:

```ruby
def create
  @dino = Dino.new(dino_params)

  respond_to do |format|
    if @dino.save
      format.html { redirect_to @dino, notice: 'Post was successfully created.' }
      format.json { render :show, status: :created, location: @dino }
    else
      format.html { render :new }
      format.json{ render json: @dino.errors, status: :unprocessable_entity }
    end
  end
end
```
> Note: docs for [respond_to](https://apidock.com/rails/ActionController/MimeResponds/InstanceMethods/respond_to)

Based on the result of `@dino.save`, the method will execute either the code in the `if` or in the `else`.  The code `format.html` or `format.json` means that Rails will understand the format asked by the user, html or JSON.  You can explore the JSON version on your own ;). So for the moment, we will only look at the lines starting with `format.html`.

In the `if` case , we can see that in the code executed in the block `redirect_to @dino, notice: 'Post was successfully created.'` This code will redirect the request to the show method. `redirect_to` the `@dino` object in rails means "go to the method to show only this object".

In the `else` case, the code executed is `render :new` - this means, Rails will show the template `app/views/dino/new.html.erb`. This template uses an instance variable `@dino`. In this case, it will use the instance variable defined at the start of the create method.

To sum it up, Rails will, by default, render the template that has the name of the current method in the controller, unless there is a `render` statement in the method that tells Rails to use a different template, for example, after performing the action.

There are different syntaxes for render, and they all do the same action described above but the rule of thumb is to use the simplest one that makes sense for the code you are writing.

> Talk to the neighbor (3 mins): Review and explain each of the render functions below.

```ruby
render :edit
render action: :edit
render "edit"
render "edit.html.erb"
render action: "edit"
render action: "edit.html.erb"
render "books/edit"
render "books/edit.html.erb"
render template: "books/edit"
render template: "books/edit.html.erb"
render "/path/to/rails/app/views/books/edit"
render "/path/to/rails/app/views/books/edit.html.erb"
render file: "/path/to/rails/app/views/books/edit"
render file: "/path/to/rails/app/views/books/edit.html.erb"
```

> Note: [Docs for ^](http://guides.rubyonrails.org/layouts_and_rendering.html#using-render)

#### Great, we have an action to create a dino! Now we need to create a view for it!

#### Using partials

A best practice is to always keep every template as small as possible. A rule of thumb would be to keep shorter than 50 lines, for the sake of readability.

So for example, if your website has a layout with a top menu, the content and then the footer, this should all be in the layout, as it is rendered on every page.  But if all this html is in one file, the layout will end up being 200+ lines of code.

When this happens, you should think about splitting the template into partials. Partials are just chunks of a template that will be rendered into another one, like children of the layout.

Create a new file:

```bash
mkdir app/views/application
touch app/views/application/_header.html.erb
```

And inside move the following from `application.html.erb`:

```erb
<header>
  <h1>My Website for Dinos!</h1>  
  <ul>
    <li><%link_to 'See all Dinos', dinos_path%></li>
    <li>Maybe some other menu item</li>
    <li>And another menu item</li>
  </ul>
</header>
```

#### You do: 💪 (10 min)

Awesome, we separated the header to be a partial. Now YOU, take 10 min and make another partial for `footer`, don't forget to include it in the `application.html.erb`


### Now let's create views for `create` action:

First, create a `new.html.erb` in the `dinos` views folder
Second, create a `_form` partial in the `dinos` views folder and render it from the `new` file.

here is the code for the `_form`:

```ruby
<%= form_for(@dino) do |f| %>

  <div class="field">
    <%= f.label :name %><br>
    <%= f.text_field :name %>
  </div>
  <div class="field">
    <%= f.label :color %><br>
    <%= f.text_area :color %>
  </div>
  <div class="field">
    <%= f.label :breed %><br>
    <%= f.text_area :breed %>
  </div>
  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>

```

Let's build out the rest of the CRUD functionality:
**Update:**

```ruby
# hmmmm what is this post_params? - Defined as "private method"
  def update
    respond_to do |format|
      if @dino.update(dino_params)
        format.html { redirect_to @dino, notice: 'Post was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end
```

**Delete:**

```ruby

 def destroy
    @dino.destroy
    respond_to do |format|
      format.html { redirect_to dinos_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

```

**Set up private methods:**

```ruby
before_action :set_dino, only: [:show, :edit, :update, :destroy]

  private
    # Use callbacks to share common setup or constraints between actions.
    # get the :id params from the url to be passed to each action
    def set_dino
      @dino = Dino.find(params[:id])
    end

    # params object is being generated on every form to be passed to the corresponding action
    # Never trust parameters from the scary internet, only allow the white list through.
    def dino_params
      params.require(:dino).permit(:name, :age, :color, :breed)
    end
```

## Integrating Layouts - Codealong (30 mins)

Open the dinos controller and look at how each method renders the templates: some of them, like index and show, are abstract because the name of the template is the name of the method, but for some other methods, like create or update, we need to explicitly tell Rails what to do at the end of the method.

#### Different Layouts

By default, Rails will render the layout `application.html.erb` - but sometimes, you want to render a template in a different layout.

For instance, let's create a layout called `sidebar.html.erb`

```bash
touch app/views/layouts/sidebar.html.erb
```

Take this template and add it into the `sidebar.html.erb`:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Sidebar Template</title>
</head>
<body>
  <header>
    <h1>My Website for Dinos</h1>  
    <ul>
      <li>Menu 1</li>
      <li>Menu 2</li>
      <li>Menu 3</li>
      <li>Menu 4</li>
    </ul>
  </header>
  <main>
    <%= yield %>
  </main>
  <footer>
    <ul>
      <li>About us</li>
      <li>Team</li>
      <li>Terms and conditions</li>
    </ul>
  </footer>
</body>
</html>
```

This will help us to differentiate the layouts.

In the controller method `index`, add this to the end of the method:

```ruby
render layout: 'sidebar'
```

This line will just tell Rails to use the same logic of template rendering, but instead of using the default `application.html.erb`, it will render the template inside `sidebar.html.erb`.

I know this may not seem like super useful right now, but when you build a larger application, you may need a special layout for "super_user", admin ;)

#### Surprise Bonus:
Create a rails app using [ Scaffold](http://guides.rubyonrails.org/v3.2.8/getting_started.html#getting-up-and-running-quickly-with-scaffolding)   😱😱😱😱😱😱😱

## Conclusion (10 mins)

#### Questions

- Where do we use the method `render` (2 places)
- What is the easiest way to go to the show page of a restful controller from another method in this controller?
- How to render a different layout only for one method?
