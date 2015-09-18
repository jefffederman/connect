if defined?(Rack::Timeout)
  Rack::Timeout.timeout = (ENV["TIMEOUT_IN_SECONDS"] || 180).to_i
end
