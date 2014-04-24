#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'optparse'
require 'ostruct'

class RailsLogBlockGrep
  ::Version = [0,0,2]
  ::GREP_COLOR = "01;31" # bold red

  attr_accessor :options, :pattern

  $stdout.sync = true
  Signal.trap(:INT, :EXIT)

  def initialize(args)
    # Handle options
    @options = OpenStruct.new
    @options.color = 'auto'

    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: #{$0} [OPTION]... PATTERN [FILE]..."

      opt.on('-c [always|never|auto]', '--color [always|never|auto]', ["always", "never", "auto"], 'Colorize matching string with GREP_COLOR variable. See grep(1) manpage.') do |color|
        @options.color = color
      end

      opt.on('-s', '--[no-]seperator', 'Print a separator between records.') do |s|
        @options.separator = s
      end

      opt.on_tail("-h","--help","Print usage information.") do
        $stderr.puts opt_parser
        exit 1
      end

      opt.on_tail("--version", "Show version") do
        puts ::Version.join('.')
        exit 1
      end
    end

    begin 
      opt_parser.parse!
    rescue OptionParser::InvalidOption => e
      $stderr.puts "Specified #{e}"
      $stderr.puts opt_parser
      exit 64 # EX_USAGE
    end

    # ARGV check - must include at least 2 args
    unless ARGV.length >= 2
      $stderr.puts opt_parser
      exit 64 # EX_USAGE
    end

    # extract pattern
    @pattern = ARGV.shift
    unless pattern
      $stderr.puts opt_parser
      exit 64 # EX_USAGE
    end
  end

  # run function
  def run!
    # color
    case @options.color
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

    # Loop over ARGF and output matching blocks
    block = ''
    buffer = ''
    begin
      while input = ARGF.gets
        input.each_line do |line|
          # If the line begins with Started, we have a new block, so process
          # the old and start a new buffer. Customize this regex for different
          # log formats.
          if (line =~ /^Started.*?/uo)
            block = buffer
            buffer = line
          else
            buffer += line
          end

          if block.match(/#{pattern}/muo)
            # matched block
            $stdout.puts block.gsub(/#{pattern}/){ |match|
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
            $stdout.puts "--" if @options.separator
          end

          # clear block
          block = ''
        end
      end
    rescue Errno::EPIPE
      exit 74 # EX_IOERR
    end
  end
end

if $0 == __FILE__
  RailsLogBlockGrep.new(ARGV).run!
end
