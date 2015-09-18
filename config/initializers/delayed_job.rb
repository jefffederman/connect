require "delayed_raygun"

Delayed::Worker.max_attempts = 4
Delayed::Worker.plugins << DelayedRaygun
