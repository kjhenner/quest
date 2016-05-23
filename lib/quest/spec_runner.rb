module Quest

  module SpecRunner

    include Quest::Messenger

    require 'serverspec'
    require 'rspec/autorun'

    # The serverspec os function creates an infinite loop.
    # Setting it manually prevents the function from running.
    # Note that this is a temporary workaround, and this data is wrong!
    set :os, {}
    set :backend, :exec

    def run_specs(spec_path, output_path)
      config = RSpec.configuration

      # Disable Standard out
      config.output_stream = File.open("/dev/null", "w")

      # This is some messy reach-around coding to get the JsonFormatter to work
      formatter = RSpec::Core::Formatters::JsonFormatter.new(config.output_stream)
      reporter  = RSpec::Core::Reporter.new(config)
      config.instance_variable_set(:@reporter, reporter)
      loader = config.send(:formatter_loader)
      notifications = loader.send(:notifications_for, RSpec::Core::Formatters::JsonFormatter)
      reporter.register_listener(formatter, *notifications)
      # End workaround

      # Run the test
      Quest::LOGGER.info("Beginning run of tests in #{spec_path}")
      RSpec::Core::Runner.run([spec_path])

      # Store test results
      File.open(output_path, "w"){ |f| f.write(formatter.output_hash.to_json) }
      Quest::LOGGER.info("RSpec output written to #{output_path}")

      # Clean up for next spec
      RSpec.reset
      Quest::LOGGER.info("RSpec reset")
    end

    def load_helper(helper_path)
      # Require a spec_helper file if it exists
      if File.exists?(helper_path)
        require helper_path
        Quest::LOGGER.info("Loaded spec helper at #{helper_path}")
      else
        Quest::LOGGER.info("No spec helper file found at #{helper_path}")
      end
    end
  end

end
