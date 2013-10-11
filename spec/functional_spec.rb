require 'spec_helper'

describe "functional test" do

  let(:file_path) { 'spec/tmp/pool_test.txt' }
  before { File.delete file_path if File.exists? file_path }

  it "delegates to workers" do
    # given
    pool = Pool.new(50) do |queue|
      Worker.new(queue).process
    end
    pool.start

    # when
    1000.times do |num|
      pool.schedule do
        File.open(file_path, "a+") { |f|
          f << "Line number: #{num}\n"
        }
      end
    end
    sleep 1
    # pool.shutdown

   # expect
   File.readlines(file_path).size.should == 1000
  end

end
