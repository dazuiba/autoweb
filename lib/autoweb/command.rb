require 'autoweb/ui'
module Autoweb
  module Command
    class Base
      include Autoweb::UI
      attr_accessor :args   
      
      def initialize(args)
        @args = args             
      end          
      
      def usage
      <<-EOTXT
=== Command List:
  automan console
  automan dbconsole
  automan help
  automan update
 

EOTXT
    	end
      
    end
    class InvalidCommand < RuntimeError; end
    class CommandFailed  < RuntimeError; end

    class << self
      
      include Autoweb::UI
      def run(command, args, retries=0)
        begin         
          run_internal(command, args.dup)
        rescue InvalidCommand
          error "Unknown command. Run 'autoweb help' for usage information."
        rescue CommandFailed => e
          error e.message
        rescue Interrupt => e
          error "\n[canceled]"
        end
      end

      def run_internal(command, args)
        klass, method = parse(command)
        runner = klass.new(args)
        raise InvalidCommand unless runner.respond_to?(method)
        runner.send(method)
      end

      def parse(command)
        parts = command.split(':')
        case parts.size
          when 1
            begin
              return eval("Autoweb::Command::#{command.capitalize}"), :index
            #rescue NameError, NoMethodError
            #  return Autoweb::Command::Help, command
            end
          when 2
            begin
              return Autoweb::Command.const_get(parts[0].capitalize), parts[1]
            rescue NameError
              raise InvalidCommand
            end
          else
            raise InvalidCommand
        end
      end
    end
  end
end

Dir["#{File.dirname(__FILE__)}/../../commands/*.rb"].each { |c| 
	unless (/_helper\.rb$/=~c)
		require c 
	end
}