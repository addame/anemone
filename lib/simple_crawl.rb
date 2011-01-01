$: << File.expand_path('..', __FILE__) 
$: << File.expand_path('../anemone', __FILE__)
$: << File.expand_path('../anemone/storage', __FILE__)


require "anemone"
require 'anemone/exceptions'
require 'anemone/page_store'
require 'anemone/storage'
require 'anemone/storage/base'


@url = URI("http://www.example.com/")

storage = Anemone::Storage::Base.new(Anemone::Storage.Hash) # toutes les possibilités : Redis, Hash, MongoDB, PStore, TokyoCabinet
#storage = Anemone::Storage::Base.new(Anemone::Storage.MongoDB({:recreate=>false,:host=> nil, :port=> nil, :pool_size=> 1, :timeout==> 5}))
@pages_store = Anemone::PageStore.new(storage)

return if @pages_store.has_page?(@url)

Anemone.crawl(@url) do |anemone|
  anemone.delay = 0; anemone.threads = 2; anemone.obey_robots_txt = true; anemone.redirect_limit = 5; anemone.accept_cookies = true 
  #anemone.depth_limit = 1
  # follow only links that are not present in the store
  anemone.focus_crawl{ |page| page.links.select{|link| !@pages_store.has_page?(link)} }
  
  anemone.on_every_page { |page| 
    # sauvegarder l'url, sauvegarder les autres liens découverts qui n'y sont pas déjà 
    @pages_store.touch_key page.url
    @pages_store.touch_keys(@pages_store.new_links(page.all_links))
    @pages_store[page.url] = page
    puts "---------------------------------------------------------"
    puts "- url = #{page.url.to_s}"
    puts "- code = #{page.code}"
    #puts "- content = #{page.doc.inner_text if page.doc}"
  }
  #
  
  
end