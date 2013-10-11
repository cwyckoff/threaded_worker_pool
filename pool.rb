require 'thread'

class Pool
  attr_reader :queue, :size, :worker, :workers

  def initialize(size, &block)
    @size = size.to_i
    @queue = Queue.new
    @worker = block
  end

  def add_worker
    @workers << new_worker
  end

  def start
    @workers ||= Array.new(size) do
      new_worker
    end
  end

  def schedule(&block)
    queue << block
  end

  def shutdown
    size.times { schedule { throw :exit } }
    workers.map(&:join)
  end

  private

  def new_worker
    Thread.new do
      worker.call(queue)
    end 
  end

end
