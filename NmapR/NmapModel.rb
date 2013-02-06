require 'rubygems'
require 'nmap/program'

attr_accessor :targets, :ports

def scan()
	Nmap::Program.scan do |nmap|
        ## these are disabled since they require root
        nmap.syn_scan = false
        nmap.os_fingerprint = false
        ##
        
        nmap.service_scan = true
        nmap.xml = 'scan.xml'
        nmap.verbose = false
        nmap.ports = ports
        nmap.targets = targets
	end
    
end