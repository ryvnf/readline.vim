readline.vim
============

Readline is a library used for implementing line editing across many
command-line tools (including `bash` and other shells and interpreters).
Readline ships with a default set of key-bindings that you are probably already
familiar with.

The readline default bindings is a mixture of traditional UNIX and EMACS
bindings. Here are some examples:

- `^A` cursor to start of line
- `^E` cursor to end of line
- `^B` cursor forward
- `^F` cursor forward
- `^U` delete to start of line
- `^K` delete to end of line

This plugins implements a subset of readline's default keyboard commands to
Vim's command-mode. Mappings available include deletion and navigation by words
and other useful stuff. By using this plugin you get the same interface when
editing command-lines in Vim as you do in your favorite shell!

For a full list of all the commands added by this plugin. Do `:help readline`
after updating the helptags to include the tags in the [doc directory](doc) of
this repository. If you have not downloaded this plugin, but want to learn
more, you can read the [documentation file](./doc/readline.txt) right now!

License
-------

This plugin is distributed under the Vim license. See `:help license` from
within Vim to learn more.
