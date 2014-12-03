require 'dacker'
require 'spec_helper'
require 'pry'

describe Dacker::Container, "container"  do
  let(:docker) { ::Docker::Connection.new('tcp://localhost:5000',{}) }

  context "when the container exists + not running" do
    before do
      @container = Docker::Container.create({'Cmd' => ['bash'], 'Image' => 'ubuntu'}, docker)
    end

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

    it "should return it when running is false" do
      expect(container.container(false).id).to eq(@container.id)
    end

    it "should not return it when running is true" do
      expect(container.container(true)).to be_nil
    end
  end
end
