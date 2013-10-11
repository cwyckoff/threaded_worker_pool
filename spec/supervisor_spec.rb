require 'spec_helper'

describe Supervisor do

  let(:msg) { {} }
  let(:pool) {
    p = Pool.new(2) do |queue|
      Worker.new(queue).process
    end
    p.start
    p
  }
  let(:supervisor) {
    Supervisor.new(pool) { |msg| {} }
  }
  let!(:dead_worker) { pool.workers.last.object_id }

  describe "#process" do

    context "workers have died" do

      before {
        pool.workers.last.kill
        sleep 0.01
      }

      it "removes dead workers" do
        # when
        supervisor.process(msg)

        # expect
        supervisor.workers.map(&:object_id).should_not include(dead_worker)
      end

      it "adds new workers to replace dead ones" do
        # when
        supervisor.process(msg)

        # expect
        supervisor.workers.size.should == 2
      end

    end

    context "no workers have died" do

      it "does not manage worker pool" do
        # expect
        pool.should_not_receive(:add_worker)

        # when
        supervisor.process(msg)
      end

    end

    it "delegates messages to the worker pool" do
      # expect
      pool.should_receive(:schedule)

      # when
      supervisor.process(msg)
    end
  end

end
