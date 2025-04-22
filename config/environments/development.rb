require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Use a custom exceptions app in development to show more detailed errors
  config.exceptions_app = ->(env) do
    request = ActionDispatch::Request.new(env)
    exception = env["action_dispatch.exception"]
    trace = exception.backtrace.join("\n")
    
    content = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>Error: #{exception.class.name}</title>
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            padding: 20px;
            max-width: 1200px;
            margin: 0 auto;
            line-height: 1.5;
          }
          .header {
            border-bottom: 1px solid #ccc;
            margin-bottom: 20px;
            padding-bottom: 10px;
          }
          .error-message {
            padding: 10px;
            border-radius: 5px;
            background-color: #ffebee;
            border: 1px solid #ffcdd2;
            margin-bottom: 20px;
          }
          .trace {
            background-color: #f5f5f5;
            border-radius: 5px;
            padding: 10px;
            overflow-x: auto;
            font-family: monospace;
            white-space: pre;
          }
          .section {
            margin-bottom: 20px;
          }
          h2 {
            color: #333;
            margin-top: 25px;
          }
          .request-details {
            font-family: monospace;
            background-color: #f8f8f8;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
          }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>Error: #{exception.class.name}</h1>
        </div>
        
        <div class="section">
          <h2>Error Message</h2>
          <div class="error-message">
            <strong>#{exception.message}</strong>
          </div>
        </div>
        
        <div class="section">
          <h2>Stack Trace</h2>
          <div class="trace">#{trace}</div>
        </div>
        
        <div class="section">
          <h2>Request Details</h2>
          <div class="request-details">
            <strong>URL:</strong> #{request.url}<br>
            <strong>HTTP Method:</strong> #{request.request_method}<br>
            <strong>Remote IP:</strong> #{request.remote_ip}<br>
            <strong>Parameters:</strong> #{request.parameters.inspect}<br>
            <strong>Query String:</strong> #{request.query_string}<br>
          </div>
        </div>
      </body>
      </html>
    HTML
    
    [500, {"Content-Type" => "text/html"}, [content]]
  end

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "local").to_sym

  # Set Active Storage URL expiration time to 7 days
  config.active_storage.urls_expire_in = 7.days

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :letter_opener

  config.action_mailer.perform_caching = false

  config.action_mailer.perform_deliveries = true

  config.action_mailer.default_url_options = { host: "localhost", port: ENV.fetch("PORT") { 3000 } }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

  # Apply autocorrection by RuboCop to files generated by `bin/rails generate`.
  config.generators.apply_rubocop_autocorrect_after_generate!

  # Allow connection from any host in development
  config.hosts = nil
end
