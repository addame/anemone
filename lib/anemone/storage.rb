module Anemone
  module Storage

    def self.Hash(*args)
      hash = Hash.new(*args)
      # add close method for compatibility with Storage::Base
      class << hash; def close; end; end
      hash
    end

    def self.PStore(*args)
      require 'anemone/storage/pstore'
      self::PStore.new(*args)
    end

    def self.TokyoCabinet(file = 'anemone.tch')
      require 'anemone/storage/tokyo_cabinet'
      self::TokyoCabinet.new(file)
    end

    def self.MongoDB(mongo_db = nil, collection_name = 'pages',params = {})      
      require 'anemone/storage/mongodb'
      @host     = params[:host]      || nil
      @port     = params[:port]      || nil
      @pool_size= params[:pool_size] || 1
      @timeout  = params[:timeout=]  || 5
      mongo_db ||= Mongo::Connection.new(@host,@port,{:pool_size=>@pool_size,:timeout=>@timeout}).db('anemone')
      raise "First argument must be an instance of Mongo::DB" unless mongo_db.is_a?(Mongo::DB)
      self::MongoDB.new(mongo_db, collection_name,:recreate=>params[:recreate])
    end

    def self.Redis(opts = {})
      require 'anemone/storage/redis'
      self::Redis.new(opts)
    end

  end
end
