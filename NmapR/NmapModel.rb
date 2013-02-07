require 'rubygems'
require 'nmap/program'
require 'nmap/xml'

class NmapModel < OSX::NSObject
    attr_accessor :targets, :ports, :service_scan, :verbose, :skip_discovery, :result
    
    FILENAME = "scan.xml"
    
    def scan_it()
        success = Nmap::Program.scan do |nmap|
            ## these are disabled since they require root
            nmap.syn_scan = false
            nmap.os_fingerprint = false
            ##
            
            nmap.service_scan = service_scan
            nmap.verbose = verbose
            nmap.xml = FILENAME
            nmap.ports = ports
            nmap.targets = targets
            nmap.skip_discovery = skip_discovery
        end
        
        if success
            parse_it()
        else
            return false
        end
    end
    
    def parse_it()
    	@result = []
    	Nmap::XML.new(FILENAME) do |xml|
            xml.each_host do |host|
    			@result.push("[#{host.ip}]\n")
                
    			host.each_port do |port|
      				@result.push("  #{port.number}/#{port.protocol}\t#{port.state}\t#{port.service}\n")
                end
            end
        end
    end
end
