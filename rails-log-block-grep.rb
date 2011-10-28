#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'optparse'

::Version = "0.0.1"

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

def main()
  # option
  options = {}
  opts = OptionParser.new
  opts.banner = "Usage: #{$0} [OPTION]... PATTERN [FILE]..."
  opts.on('-A NUM', '--after-context NUM', 'Print NUM blocks of trailing context after matching block.'){ |num|
    options['after_context'] = num
  }
  opts.on('-B NUM', '--before-context NUM', 'Print NUM blocks of leading context before matching block.'){ |num|
    options['before_context'] = num
  }
  opts.on('-C NUM', '--context NUM', 'Print  NUM  blocks of output context.'){ |num|
    options['context'] = num
  }
  opts.parse!
  
  # pattern
  pattern = ARGV.shift
  unless pattern
    puts opts.help
    exit!
  end
  
  # context
  before_context = after_context = options["context"].to_i
  before_context = options["before_context"].to_i unless options["before_context"].nil?
  after_context  = options["after_context"].to_i  unless options["after_context"].nil?
  
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
        "\e[01;36m#{match}\e[0m"
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
