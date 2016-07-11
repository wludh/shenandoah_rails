# Shenandoah Index
Front-end interface for searching the an index of the Shenandoah Literary Journal. Implemented in rails, it populates the pages by querying and parsing a JSON API. What follows is a breakdown of some important files/directories used in the rails app for people new to the project looking to tweak, fix, upgrade, or template things.

## Assets
* /app/assets/images - contains all images used.
* /app/assets/stylesheets/custom.css - where all our custom styles go. imported last and will override the default boostrap styles.
* /Gemfile - contains all dependencies and ruby libraries that are loaded.

## Logic
* /app/controllers/pages_controller.rb - the master file for all the logic underlying the site. API endpoint, available JSON queries, and logic for providing data to the site's pages are defined here. Besides all that, it also contains the index method, which is where the index page gets all of its data from everything else. So if you define a variable there, it will be available to the index page's view.

## Views

The site (and rails more genreally) generates by combining a number of pieces or **partials** of files located in /app/views/layouts - so you'll need to know where the various pieces are. Much of rails consists of just knowing where to look to modify the particular piece of the site that you're interested in.

**Template-level elements**

* /app/views/application.html.erb - outermost shell for the site that imports the other various pieces. Nav and footer are imported by default, and then, in the middle, it will stick in whatever particular page the user happens to be on.
* /app/views/layouts/_nav.html.erb - imported on every page, contains the header information including references to stylesheets, etc.
* /app/views/layouts/_footer.html.erb - imported on every page, contains the footer for the site.

**Page-level elements**

* /app/views/about.html.erb - the about page
* /app/views/index.html.erb - the index page. by default imports the browse tree, search form, and results sections.
* /app/views/index.html+phone.erb - special index page shown only to phone users. yanks out the browse tree because it was not particularly responsive and making the site unusable on phones.

**Individual components for index page**

* /app/views/layouts/_browse.html.erb - the partial containing the browse tree.
* /app/views/layouts/_search.html.erb - partial containing the search form.
* /app/views/layouts/_results.html.erb - partial containing the results

## Links

* /config/routes.rb - contains all of the links for the project (expect for those generated dynamically on the fly using parameters from the browse tree).

## Testing

/spec/controllers/page_spec.rb and /spec/features/index_spec.rb - contain the tests for the site. When upgrading, you can run 

```bash
$ rspec spec
```

to make sure that nothing has broken. The tests should point you in the right direction. And changing to a new API will automattically break a lot of the tests, and these tests can help get you started to make sure you are rebuilding things correctly.

