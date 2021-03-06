# Polisher Yum Operations
#
# Licensed under the MIT license
# Copyright (C) 2013 Red Hat, Inc.

require 'pkgwat'

module Polisher
  class Yum
    YUM_CMD = '/usr/bin/yum'

    # Retrieve version of gem available in yum
    #
    # @param [String] name name of gem to loopup
    # @param [Callable] bl optional callback to invoke with version retrieved
    # @returns [String] version of gem in yum or nil if not found
    def self.version_for(name, &bl)
      version = nil
      out=`#{YUM_CMD} info rubygem-#{name} 2> /dev/null`
      if out.include?("Version")
        version = out.lines.to_a.find { |l| l =~ /^Version.*/ }
        version = version.split(':').last.strip
      end
      bl.call(:yum, name, [version]) unless(bl.nil?) 
      version
    end
  end
end
