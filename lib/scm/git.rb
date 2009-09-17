module RailsRefactor
  module SCM
    class Git < Abstract
      def move(from, to)
        `git mv #{from} #{to}`
      end
    end
  end
end
