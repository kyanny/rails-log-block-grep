# rails-log-block-grep.rb

Ruby on Rails log grep utility.

More suitable than grep(1) because it can match entire request blocks, rather than single lines.

## Install

Download from Github using curl. Save this somewhere in your $PATH with execute permissions if you'd like.

    $ curl -O https://raw.github.com/kyanny/rails-log-block-grep/master/rails-log-block-grep.rb

## Usage

Requires Ruby. Confirmed to work with 1.9.3, and 2.1.1. For specific usage, please refer to the help.

    $ ruby rails-log-block-grep.rb -h

## Issues

For bugs in the original script, please submit an issue to the Author's repository [https://github.com/kyanny/rails-log-block-grep/issues](https://github.com/kyanny/rails-log-block-grep/issues).

## Recent Changes

#### Compatible Rails Version

The master branch now works with Rails 3 default logging format. It does not work with Rails 2 or tagged loggers.

#### Notes On Log Parsing Strategy

This script uses a new, but naive log parsing methodology. Previous versions of this script used `gets("")`, which pulled in blocks of the file delimited by blank lines. Rails defaults no longer use these blank lines, making this strategy ineffective.

The new strategy is to process line-by-line, buffering lines internally until we find a line beginning with the string "Started". At that point, all buffered lines are transfered to a block, which is examined for a match against the specified pattern. The block is reset after output.

This means that the tool will only work with Rails logs using the standard "Started" convention. Rails 2 logs do not use this convention, and anyone using newer tagged logging strategies will note that their logs are not parsed correctly. However, altering the script to locate the beginning of a new log block should be trivial.

#### No more before/after context

Unfortunately, because we can't pull in log blocks using `gets("")` any more, it is not nearly as trivial to present before and after context. I am working on getting that functionality back though.

## Author

Kensuke Nagae &lt;kyanny at gmail dot com&gt;

## Contributor

Brad Landers (@bradland)
