require 'spec_helper'

describe Chake::Backend::Ssh do

  include_examples "Chake::Backend", Chake::Backend::Ssh

  let(:node) { Chake::Node.new('ssh://myuser@myhost/srv/chef') }

  it('runs commands with ssh') { expect(backend.command_runner).to eq(['ssh', 'myuser@myhost']) }

  it('rsyncs over ssh') { expect(backend.rsync_dest).to eq('myuser@myhost:/srv/chef/') }

  it 'uses no remote username if none was passed' do
    node = Chake::Node.new('theserver')
    expect(node.username).to eq(Etc.getpwuid.name)
    expect(node.remote_username).to be_nil
  end

  it 'uses username is passwd' do
    expect(node.username).to eq('myuser')
    expect(node.remote_username).to eq('myuser')
  end

  context 'with a custom port' do
    let(:node) { Chake::Node.new('ssh://myhost:2222') }
    it 'uses port with ssh' do
      expect(backend.command_runner).to eq(['ssh', '-p', '2222', 'myhost'])
    end
    it 'uses port with scp' do
      expect(backend.scp).to eq(['scp', '-P', '2222'])
    end
    it 'uses port with rsync' do
      expect(backend.send(:rsync_ssh)).to eq(['-e', 'ssh -p 2222'])
    end
  end

end
