require 'rubygems'
require 'nmap/program'

class NmapModel

    attr_accessor :targets, :ports, :service_scan, :verbose, :skip_discovery
    
    def scan()
        Nmap::Program.scan do |nmap|
            ## these are disabled since they require root
            nmap.syn_scan = false
            nmap.os_fingerprint = false
            ##
            
            nmap.service_scan = true
            nmap.verbose = false
            nmap.xml = true
            nmap.ports = ports
            nmap.targets = targets
            nmap.skip_discovery = skip_discovery
        end
        
    end

end