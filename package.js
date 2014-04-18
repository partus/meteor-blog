Package.describe({
  summary: "A package that provides a blog at /blog"
});

Package.on_use(function(api) {

  var both = ['client', 'server'];

  /**
   * Packages for client
   */

  api.use([
    'session',
    'templating',
    'ui',
    'less',
    'reactive-table'
  ], 'client');

  /**
   * Files for client
   */

  api.add_files([
    'client/stylesheets/lib/medium-editor.css',
    'client/stylesheets/lib/medium-themes/bootstrap.css',
    'client/boot.coffee',
    'client/compatibility/medium-editor.js',
    'client/views/404.html',
    'client/views/admin/admin.less',
    'client/views/admin/admin.html',
    'client/views/admin/admin.coffee',
    'client/views/admin/edit.html',
    'client/views/admin/edit.coffee',
    'client/views/blog/blog.less',
    'client/views/blog/blog.html',
    'client/views/blog/show.html',
    'client/views/blog/blog.coffee'
  ], 'client');

  /**
   * Files for server
   */

  api.add_files([
    'collections/config.coffee',
    'server/boot.coffee',
    'server/rss.coffee',
    'server/publications.coffee'
  ], 'server');

  /**
   * Packages for server
   */

  Npm.depends({rss: '0.0.4'});

  /**
   * Packages for server and client
   */

  api.use([
    'coffeescript',
    'iron-router',
    'accounts-base',
    'minimongoid',
    'moment',
    'roles'
  ], both);

  /**
   * Files for server and client
   */

  api.add_files([
    'router.coffee',
    'collections/author.coffee',
    'collections/post.coffee'
  ], both);
});

Package.on_test(function (api) {
  api.use('blog', ['client', 'server']);
  api.use('tinytest', ['client', 'server']);
  api.use('test-helpers', ['client', 'server']);
  api.use('coffeescript', ['client', 'server']);

  api.add_files('test/server/rss.coffee', 'server');
});
