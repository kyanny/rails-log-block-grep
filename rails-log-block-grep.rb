#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'optparse'

::Version = "0.0.1"
::GREP_COLOR = "01;31" # bold red

$stdout.sync = true
Signal.trap(:INT, :EXIT)

# SimpleQueue for context queue
class SimpleQueue
  def initialize(max)
    @max = max
    @queue = Array.new(max)
  end
  
  def clear
    @queue = []
  end
  
  def empty?
    @queue.empty?
  end
  
  def num_waitihg
    raise NotImplementedError
  end
  
  def length
    @queue.length
  end
  alias :size :length
  
  def max
    @max
  end
  
  def max=(n)
    @max = n
  end
  
  def pop
    @queue.shift
  end
  alias :shift :pop
  alias :deq :pop

  def push(*items)
    items.each do |item|
      @queue << item
      if @queue.length > @max
        @queue.shift
      end
    end
    self
  end
  alias :<< :push
  alias :enq :push
end

# main function
def main()
  # option
  options = {}
  
  opts = OptionParser.new
  opts.banner = "Usage: #{$0} [OPTION]... PATTERN [FILE]..."
  
  opts.on('-A NUM', '--after-context NUM', Integer, 'print NUM blocks of trailing context'){ |num|
    options['after_context'] = num
  }
  
  opts.on('-B NUM', '--before-context NUM', Integer, 'print NUM blocks of leading context'){ |num|
    options['before_context'] = num
  }
  
  opts.on('-C NUM', '--context NUM', Integer, 'print NUM blocks of output context'){ |num|
    options['context'] = num
  }
  
  opts.on('--colour [always|never|auto]', '--color [always|never|auto]', ["always", "never", "auto"], 'colorize matching string with GREP_COLOR variable. see grep(1) manpage.'){ |flag|
    options['color'] = flag
  }
  
  begin
    opts.parse!
  rescue OptionParser::InvalidArgument # --color without WHEN
    options['color'] = "auto"
  end
  
  # ARGV check - must include at least 2 args
  unless ARGV.length >= 2
    puts opts.help
    exit!
  end
  
  # extract pattern
  pattern = ARGV.shift
  unless pattern
    puts opts.help
    exit!
  end
  
  # context
  before_context = after_context = options["context"].to_i
  before_context = options["before_context"].to_i unless options["before_context"].nil?
  after_context  = options["after_context"].to_i  unless options["after_context"].nil?
  
  # color
  case options["color"]
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
  
  # queue
  before_queue = SimpleQueue.new(before_context)
  after_queue  = SimpleQueue.new(after_context)
  
  # loop
  while block = gets("") # paragraph mode
    
    # print separator when context is defined
    sep_done = false

    # Ruby 1.9.2
    if block.respond_to?(:encode)
      block = block.encode("UTF-16BE", :invalid => :replace, :undef => :replace, :replace => '?').encode("UTF-8")
    end
    
    # stack before context
    if before_queue.max > 0
      before_queue << block
    end
    
    if block.match(/#{pattern}/o)
      
      # clear before context
      if before_queue.length > 0
        unless sep_done
          puts "--"
          sep_done = true
        end
        
        puts before_queue.pop until before_queue.empty?
      end
      
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
      
      # clear after context
      if after_queue.length > 0
        puts after_queue.pop until after_queue.empty?
        unless sep_done
          puts "--"
          sep_done = true
        end
      end
    end

    # stack after context
    if after_queue.max > 0
      after_queue << block
    end
    
  end
end

if $0 == __FILE__
  main()
end
