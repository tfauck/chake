require 'uri'
require 'etc'
require 'forwardable'

require 'chake/backend'

module Chake

  class Node

    extend Forwardable

    attr_reader :hostname
    attr_reader :username
    attr_reader :path
    attr_reader :data

    def initialize(hostname, data = {})
      uri = URI.parse(hostname)
      if !uri.scheme && !uri.host && uri.path
        uri = URI.parse("ssh://#{hostname}")
      end
      if uri.path.empty?
        uri.path = nil
      end

      @backend_name = uri.scheme

      @hostname = uri.host
      @username = uri.user || Etc.getpwuid.name
      @path = uri.path || "/var/tmp/chef.#{username}"
      @data = data
    end

    def backend
      @backend ||= Chake::Backend.get(@backend_name).new(self)
    end

    def_delegators :backend, :run, :run_as_root, :rsync, :rsync_dest, :scp, :scp_dest, :skip?

  end

end

