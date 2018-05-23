readline.vim
============

Readline is a library used for implementing line editing across many
command-line tools (including `bash` and other shells and interpreters).
Readline ships with a default set of key-bindings that you are probably already
familiar with.  The Readline default bindings is a mixture of traditional UNIX
and EMACS bindings.

This plugins implements a subset of Readline's default keyboard commands to
Vim's command-line mode.  Mappings available include deletion and navigation by
words and other useful stuff.

Features
--------

What makes this plugin different from similar plugins is that it implements a
larger subset of the Readline mappings, and that it does a better job of
mimicking the Readline behavior for each command.

The word movement and deletion commands have different behavior between Vim and
Readline.  The biggest difference is that in Readline punctuation is always
skipped when searching for a word boundary.  Another difference is that \_
(underscore) is treated as a word delimiter.  This plugin implements the
Readline behavior for word movement and deletion commands.

Examples
--------

Following are a few examples illustrating when this plugin can be useful.  In
each example `_` is used to indicate the current cursor position.

### #1

Deleting last two elements of path argument to `:cd`.

| Command line        | Command     |
| ------------------- | ----------- |
| `:cd path/to/dir/_` | M-Backspace |
| `:cd path/to/_`     | M-Backspace |
| `:cd path/_`        |             |

### #2

Deleting path argument to `:edit` completely.

| Command line          | Command |
| --------------------- | ------- |
| `:edit path/to/file_` | C-w     |
| `:edit _`             |         |

### #3

Adding `!` to `:edit` command.

| Command line           | Command |
| ---------------------- | ------- |
| `:edit path/to/file_`  | C-a     |
| `:_edit path/to/file`  | M-f     |
| `:edit_ path/to/file`  | !       |
| `:edit!_ path/to/file` |         |

More documentation
------------------

See [the documentation](./doc/readline.txt) for documentation of all mappings
implemented by this plugin.
