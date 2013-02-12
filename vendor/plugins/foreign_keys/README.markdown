Foreign Keys Plugin
===================

This plugin adds basic support for foreign keys, by providing some additional
schema statements as well as integration into the standard schema dumper.

Currently, mysql and postgresql connection adapters are supported.

Installation
------------

Via standard git clone:

    git clone git://github.com/dwalters/foreign_keys.git vendor/plugins/foreign_keys

Via rails plugin (requires 2.1):

    script/plugin install git://github.com/dwalters/foreign_keys.git

Adding Foreign Keys
-------------------

Just place the appropriate statements in your migrations.  The simplest example is:

    add_foreign_key :orders, :user_id

The usual rails conventions are used to deduce that this should result in a
foreign key from the `orders.user_id` column to the `users.id` column

Of course, you may specify these values explicitly too, and will need to when
the conventions don't match exactly:

    add_foreign_key :articles, :author_id, :references => :users

Some other options of note:

* `references`: the name of the referenced table
* `keys`: the corresponding column name(s) in the referenced table
* `on_delete` / `on_update`: one of `:restrict`, `:set_null`, `:cascade`
* `name`: the name to assign to the foreign key constraint

Note that recent mysql versions will create an index on the referenced
column(s) if one does not already exist.

You may wish to check the documentation for further options.

Removing Foreign Keys
---------------------

You can remove foreign keys by name:

    remove_foreign_key :orders, :name => "index_orders_on_user_id"

Or the name can be deduced if you used standard conventions when you created it:

    remove_foreign_key :orders, :user_id

This will not automatically remove any indexes.

Schema Dump
-----------

The usual rake targets for `db:schema:dump`, `db:schema:load`, and `db:reset`
should all work as desired.

Author
------

Dan Walters

<http://github.com/dwalters/foreign_keys>

Max Lapshin -- PostgreSQL support
