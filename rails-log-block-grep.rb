#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'optparse'
require 'ostruct'

::Version = "0.0.2"
::GREP_COLOR = "01;31" # bold red

$stdout.sync = true
Signal.trap(:INT, :EXIT)

# main function
def main()
  # option
  options = OpenStruct.new
  options.color = 'auto'

  opt_parser = OptionParser.new do |opt|
    opt.banner = "Usage: #{$0} [OPTION]... PATTERN [FILE]..."

    opt.on('-c [always|never|auto]', '--color [always|never|auto]', ["always", "never", "auto"], 'Colorize matching string with GREP_COLOR variable. See grep(1) manpage.') do |color|
      options.color = color
    end

    opt.on('-s', '--[no-]seperator', 'Print a separator between records.') do |s|
      options.separator = s
    end

    opt.on("-h","--help","Print usage information.") do
      puts opt_parser
    end
  end

  opt_parser.parse!

  # ARGV check - must include at least 2 args
  unless ARGV.length >= 2
    puts opt_parser
    exit!
  end

  # extract pattern
  pattern = ARGV.shift
  unless pattern
    puts opt_parser
    exit!
  end

  # color
  case options.color
  when "always"
    colorize = colorize_pipe = true
  when "never"
    colorize = colorize_pipe = false
  when "auto"
    colorize = true
    colorize_pipe = false
  else
    colorize = colorize_pipe = false
  end

  grep_color = ENV["GREP_COLOR"] || GREP_COLOR

  puts "\nSearching for pattern: #{pattern}\n\n"

  # loop
  block = ''
  buffer = ''
  begin
    while gets
      # If the line begins with Started, we have a new block, so process the old and start a new buffer
      if ($_ =~ /^Started.*?/uo)
        block = buffer
        buffer = $_
      else
        buffer += $_
      end

      if block.match(/#{pattern}/muo)
        # matched block
        puts block.gsub(/#{pattern}/){ |match|
          # colorize or not
          if     $stdout.tty? && colorize      # output to tty with color
            "\e[#{grep_color}m#{match}\e[0m"
          elsif !$stdout.tty? && colorize_pipe # output to pipe with color
            "\e[#{grep_color}m#{match}\e[0m"
          else                                 # output anywhere without color
            match
          end
        }

        # print separator
        puts "--" if options.separator
      end

      # clear block
      block = ''
    end
  rescue Errno::EPIPE
    return 0
  end
end

if $0 == __FILE__
  main()
end
