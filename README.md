reactive-publish
=====================

Enable server-side reactivity for Meteor.publish
Depends on package "server-deps"

Replace calls to "Meteor.publish" with "Meteor.reactivePublish" and
your publish function will be re-run whenever any of its dependencies
change.

This package extends "Meteor.Collection.Cursor" to be reactive in
the same manner as on the client if the options field for any of
fetch()/forEach()/map()/count()/findOne() contains "reactive: true".

This allows for the following code to work and update automatically
whenever a user changes team, or the "visibleItems" field in the user's
team changes. The result is that at any time the published collection
will contain precisely those items which should be visible to the user.

```coffeescript
Meteor.reactivePublish null, () ->
	if @userId
		user = Meteor.users.findOne {_id: @userId}, {reactive: true}

		if user.team
			team = Collections.teams.findOne {_id: user.team}, {reactive: true}
			visibleItems = _.compact(team.visibleItems)
			Collections.items.find {_id: {$in: visibleItems}}
```

```javascript
Meteor.reactivePublish(null, function() {
  if (this.userId) {
    var user = Meteor.users.findOne({_id: this.userId}, {reactive: true});
    if (user.team) {
      var team = Collections.teams.findOne({_id: user.team}, {reactive: true});
      var visibleItems = _.compact(team.visibleItems);
      return Collections.items.find({_id: {$in: visibleItems}});
    }
  }
});
```

Your publish function may also return an array of cursors (under the
same restrictions as the built-in Meteor.publish function).

The package will automatically track the IDs of published documents
to ensure that only the changes are sent to subscribed clients even
when the dependencies change and the computation is rerun.
