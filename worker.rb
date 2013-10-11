class Worker

  def initialize(queue)
    @queue = queue
  end

  def process
    catch(:exit) do
      Kernel.loop do
        job = @queue.pop
        job.call
      end
    end
  end
end
