require 'spec_helper'

describe Pool do

  describe ".new" do

    it "receives a block" do
      # when
      pool = Pool.new(10) { 1+1 }

      # expect
      pool.worker.call.should == 2
    end

  end

  describe "#start" do

    let(:pool) { Pool.new(10) {} }

    it "creates an array" do
      # when
      pool.start 

      # expect
      pool.workers.should be_an_instance_of(Array)
    end

    it "populates array with threads" do
      # when
      pool.start 

      # expect
      pool.workers.all? {|job| job.instance_of?(Thread)}.should be_true
    end

    it "limits the number of threads to a specific threshold" do
      # when
      pool.start 

      # expect
      pool.workers.size.should == 10
    end

  end

  describe "#schedule" do

    let(:pool) { Pool.new(10) {} }

    it "queues up jobs for workers" do
      # given
      count = 0
      job = Proc.new { count += 1 }

      # expect
      pool.queue.should_receive(:<<).with(kind_of(Proc))

      # when
      pool.schedule { job }
    end

  end

  describe "#shutdown" do

    let!(:pool) { Pool.new(10) {} }
    before { pool.start }

    it "schedules an 'exit' command" do
      # expect
      pool.should_receive(:schedule).exactly(10).times

      # when
      pool.shutdown
    end

    it "tells each worker to exit" do
     # expect
      pool.should_receive(:schedule).exactly(10).times

      # when
      pool.shutdown
    end

      # given
    it "joins threads" do
      # expect
      pool.workers.all? {|worker|
        worker.should_receive(:join)
      }.should be_true

      # when
      pool.shutdown
    end

  end

end
