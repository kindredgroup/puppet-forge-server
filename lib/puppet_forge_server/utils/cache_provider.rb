# -*- encoding: utf-8 -*-
#
# Copyright 2015 Centralny Osroder Informatyki (gov.pl)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'lru_redux'

module PuppetForgeServer::Utils
  module CacheProvider

    opts = PuppetForgeServer::Utils::OptionParser.DEFAULT_OPTIONS
    @@CACHE = LruRedux::TTL::ThreadSafeCache.new(opts[:ram_cache_size], opts[:ram_cache_size])

    # Method for fetching application wide cache for fetching HTTP requests
    #
    # @return [LruRedux::Cache] a instance of cache for application
    def cache_instance
      @@CACHE
    end

    # Configure a application wide cache using LSUCache implementation
    #
    # @param [int] ttl a time to live for elements
    # @param [int] size a maximum size for cache
    def configure_cache(ttl, size)
      @@CACHE = LruRedux::TTL::ThreadSafeCache.new(size, ttl)
      PuppetForgeServer::Logger.get.info("Using RAM memory LRUCache with time to live of #{ttl}sec and max size of #{size} elements")
      nil
    end
  end
end
