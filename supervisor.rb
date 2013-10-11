class Supervisor
  attr_reader :pool, :work

  def initialize(pool, &block)
    @pool = pool
    @work = block
  end

  def process(msg)
    supervise_workers do
      pool.schedule { work.call(msg) }
    end
  end

  def workers
    pool.workers
  end

  private

  def dead_workers?
    pool.workers.any? { |w| !w.alive? }
  end

  def remove_dead_workers
    pool.workers.delete_if { |w| !w.alive? }
  end

  def repopulate_workers
    return if pool.workers.size >= pool.size

    until pool.workers.size == pool.size
      pool.add_worker
    end
  end

  def supervise_workers
    if dead_workers?
      remove_dead_workers
      repopulate_workers
    end

    yield
  end

end
