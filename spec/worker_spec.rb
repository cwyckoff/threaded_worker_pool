describe Worker do

  describe "#process" do

    let(:queue) { Queue.new }
    let(:worker) { Worker.new(queue) }

    it "loops indefinitely" do
      # given
      queue = double(:pop => Proc.new {})
      worker = Worker.new(queue)

      # expect
      Kernel.should_receive(:loop).and_yield

      # when
      worker.process
    end

    it "executes a job" do
      # given
      count = 0
      job = Proc.new { count += 1 }
      Thread.new { worker.process }

      # when
      queue << job
      sleep 0.1

      # expect
      count.should == 1
    end

  end
end
