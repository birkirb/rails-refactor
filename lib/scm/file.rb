module RailsRefactor
  module SCM
    class File < Abstract
      def move(from, to)
        `mv #{from} #{to}`
      end
    end
  end
end
