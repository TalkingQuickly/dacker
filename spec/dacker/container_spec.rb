require 'dacker'
require 'spec_helper'
require 'pry'
require 'securerandom'

describe Dacker::Container do
  let(:docker) { ::Docker::Connection.new('tcp://localhost:5000',{}) }
  let (:name) { @container.json["Name"][1..-1] }
  let (:container) do
    ::Dacker::Container.new(
      {
        config: {"image" =>  "ubuntu"},
        name: name,
        host: '192.168.50.31',
        username: 'deploy'
      }
    )
  end

  describe ".container" do

    before do
      @container = Docker::Container.create({'Cmd' => ["/bin/sh", '-c', 'while true; do echo Hello World; sleep 1; done'], 'Image' => 'ubuntu'}, docker)
    end

    context "when the container exists + not running" do
      it "should return it when running is false" do
        expect(container.container(false).id).to eq(@container.id)
      end

      it "should not return it when running is true" do
        expect(container.container(true)).to be_nil
      end
    end

    context "when the container exists + running" do
      before do
        @container.start
      end

      it "should return it when when running is true" do
        expect(container.container(true).id).to eq(@container.id)
      end
    end
  end

  describe ".signal" do
    before do
      @container = Docker::Container.create({'Cmd' => ["/bin/sh", '-c', 'while true; do echo Hello World; sleep 1; done'], 'Image' => 'ubuntu'}, docker)
      @container.start
    end

    it "-9 should stop the running container" do
      expect(container.container).to_not be_nil
      container.signal(9)
      expect(container.container).to be_nil
    end
  end

  describe ".start" do
    before do
      @container = Docker::Container.create({'Cmd' => ["/bin/sh", '-c', 'while true; do echo Hello World; sleep 1; done'], 'Image' => 'ubuntu'}, docker)
    end

    it "should start the container" do
      expect(container.container).to be_nil
      container.start
      expect(container.container).to_not be_nil
    end
  end

  describe ".build" do
    let (:container) do
      ::Dacker::Container.new(
        {
          config: {"build" => File.join(File.expand_path(File.dirname(File.dirname(__FILE__))),"support","docker_build_example") },
          name: SecureRandom.hex,
          host: '192.168.50.31',
          username: 'deploy'
        }
      )

    end

    before do
      container.build
    end

    it "should build the container" do
      expect(Docker::Image.exist?(container.image,{},docker)).to eq(true)
    end
  end

end
