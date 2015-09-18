class DelayedRaygun < Delayed::Plugin
  callbacks do |lifecycle|
    lifecycle.around(:invoke_job) do |job, *args, &block|
      begin
        block.call(job, *args)
      rescue StandardError => error
        Raygun.track_exception(error)
        Rails.logger.error(error.message)
        raise error
      end
    end
  end
end
