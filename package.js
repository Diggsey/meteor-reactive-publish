Package.describe({
  name: "mrt:reactive-publish",
  summary: "Enable server-side reactivity for Meteor.publish",
  version: "0.1.7",
  git: "https://github.com/Diggsey/meteor-reactive-publish.git"
});

Package.on_use(function(api) {
  api.versionsFrom('METEOR@1.0');
  api.use([
    'coffeescript',
    'tracker',
    'underscore',
    'mrt:server-deps',
    'accounts-base'
  ], 'server');

  api.add_files('lib/reactive-publish.coffee', 'server');
});
