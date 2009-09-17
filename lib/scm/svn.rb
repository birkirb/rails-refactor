module RailsRefactor
  module SCM
    class SVN < Abstract
      def move(from, to)
        `svn mv #{from} #{to}`
      end
    end
  end
end
