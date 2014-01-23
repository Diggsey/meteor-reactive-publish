Package.describe({
  summary: "Enable server-side reactivity for Meteor.publish"
});

Package.on_use(function(api) {
  api.use('coffeescript', ['client', 'server']);
  api.use('underscore', ['server']);
  api.use('server-deps', ['server']);

  api.add_files('lib/reactive-publish.coffee', ['server']);
});
