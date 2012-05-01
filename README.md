# rails-log-block-grep.rb

Ruby on Rails log grep utility.
More suitable than grep(1) because:

- Can match entire request blocks, rather than single lines
- Can show the entire request that occurred before and after the matching request

## Install

Download from Github using curl. Save this somewhere in your $PATH with execute permissions if you'd like.

    $ curl -O https://raw.github.com/kyanny/rails-log-block-grep/master/rails-log-block-grep.rb

## Usage

Requires Ruby. Confirmed to work with 1.9.2, 1.9.3, and 1.8.7. For specific usage, please refer to the help.

    $ ruby rails-log-block-grep.rb -h

## Issues

For bugs in the original script, please submit an issue to the Author's repository [https://github.com/kyanny/rails-log-block-grep/issues](https://github.com/kyanny/rails-log-block-grep/issues).

## Author

Kensuke Nagae &lt;kyanny at gmail dot com&gt;