module Quest

  class QuestWatcher

    include Quest::Messenger
    include Quest::SpecRunner

    def initialize(daemonize=true)
      # Require serverspec here because otherwise it conflicts with
      # the gli gem.
      require 'serverspec'
      require 'rspec/autorun'

      # The serverspec os function creates an infinite loop.
      # Setting it manually prevents the function from running.
      # Note that this is a temporary workaround, and this data is wrong!
      set :os, {}
      set :backend, :exec

      @daemonize = daemonize

    end

    def restart_watcher
      if @watcher
        @watcher.pause
        Quest::LOGGER.info("Watcher paused")
        @watcher.finalize
        Quest::LOGGER.info("Watcher finalized pending runs")
        @watcher.filenames = quest_watch
        Quest::LOGGER.info("Watcher file names set to #{quest_watch}")
        @watcher.resume
        Quest::LOGGER.info("Watcher resumed")
      else
        Quest::LOGGER.info("No watcher instance found. Skipping watcher restart.")
      end
    end

    def write_pid
      begin
        File.open(PIDFILE, File::CREAT | File::EXCL | File::WRONLY){|f| f.write("#{Process.pid}") }
        Quest::LOGGER.info("PID written to #{PIDFILE}")
        at_exit { File.delete(PIDFILE) if File.exists?(PIDFILE) }
      rescue Errno::EEXIST
        check_pid
        retry
      end
    end

    def check_pid
      case pid_status
      when :running, :not_owned
        puts "The quest watcher is already running. Check #{PIDFILE}"
        exit 1
      when :dead
        File.delete(PIDFILE)
      end
    end

    def pid_status
      return :exited unless File.exists?(PIDFILE)
      pid = File.read(PIDFILE).to_i
      return :dead if pid == 0
      Process.kill(0, pid)
      :running
    rescue Errno::ESRCH
      :dead
    rescue Errno::EPERM
      :not_owned
    end

    def trap_signals
      trap(:HUP) do
        restart_watcher
      end
      Quest::LOGGER.info("Trap for HUP signal set")
    end

    def start_watcher
      Quest::LOGGER.info('Starting initial spec run')
      run_specs(spec_file, output_file)
      Quest::LOGGER.info("Initializing watcher watching for changes in #{quest_watch}")
      @watcher = FileWatcher.new(quest_watch)
      @watcher_thread = Thread.new(@watcher) do |watcher|
        watcher.watch do |changed_file_path|
          Quest::LOGGER.info("Watcher triggered by a change to #{changed_file_path}")
          run_specs(spec_file, output_file)
        end
      end
    end

    # This is the main function to set up and run the watcher process
    def run!
      if @daemonize
        check_pid
        Process.daemon
      end
      write_pid
      trap_signals
      load_helper(spec_helper)
      start_watcher
      # Keep a sleeping thread to handle signals.
      thread = Thread.new { sleep }
      thread.join
    end

  end
end
