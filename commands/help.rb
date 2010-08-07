module Autoweb::Command
  class Help < Base  
    def index
      display usage
    end

    def usage
      <<-EOTXT
=== Command List:
  autoweb baidump3 $music-name $save-to-dir
 

EOTXT
    end
  end
end