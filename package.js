Package.describe({
  summary: "Enable server-side reactivity for Meteor.publish"
});

Package.on_use(function(api) {
  api.use([
    'coffeescript',
    'deps',
    'underscore',
    'server-deps',
    'accounts-base'
  ], 'server');

  api.add_files('lib/reactive-publish.coffee', 'server');
});
