# -*- encoding : utf-8 -*-
class TimedCache
  def self.read(key, interval)
    time_checked = Rails.cache.read(TimedCache.time_key(key))        
    fetch = time_checked.nil? || Time.now - time_checked >= interval
    
    if fetch
      TimedCache.delete(key)
      return nil unless block_given?

      value = yield(key)             
      TimedCache.write(key, value) unless value.nil?
      value
    else
      time_checked.nil? ? nil : Rails.cache.read(key)
    end
  end
  
  def self.write(key, value)
    Rails.cache.write(key, value)
    Rails.cache.write(TimedCache.time_key(key), Time.now)
  end
  
  def self.delete(key)
    Rails.cache.delete(key)
    Rails.cache.delete(TimedCache.time_key(key))
  end
  
  private
  
  def self.time_key(key)
    "#{key}.time"
  end
end
