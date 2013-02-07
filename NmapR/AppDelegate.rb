#
#  AppDelegate.rb
#  NmapR
#
#  Created by Lars Mehrtens on 06.02.13.
#  Copyright (c) 2013 AWE13. All rights reserved.
#

require 'osx/cocoa'
OSX.require_framework 'CoreData'

class AppDelegate < OSX::NSObject
    ib_outlets :window, :scan_button, :reset_button, :host_text_field, :prefix_text_field, :port_text_field, :ping_checkbox, :verbose_checkbox, :result_table, :progress_indicator, :result_data_source
    attr_reader :persistentStoreCoordinator, :managedObjectModel, :managedObjectContext

    def initialize
        @nmap_model = NmapModel.new()
        @result_data_source = [[]]
    end


    def applicationDidFinishLaunching_(notification)
    end

    # Returns the directory the application uses to store the Core Data store
    # file. This code uses a directory named "cx.ath.larmeh.NmapR"
    # in the user's Application Support directory.
    def applicationFilesDirectory
        fileManager = OSX::NSFileManager.defaultManager
        appsupportURL = fileManager.URLsForDirectory_inDomains_(OSX::NSApplicationSupportDirectory, OSX::NSUserDomainMask).lastObject
        return appsupportURL.URLByAppendingPathComponent_("cx.ath.larmeh.NmapR")
    end

    # Creates if necessary and returns the managed object model for the application.
    def managedObjectModel
        if @managedObjectModel
            return @managedObjectModel
        end

        modelURL = OSX::NSBundle.mainBundle.URLForResource_withExtension_("NmapR", "momd")
        @managedObjectModel = OSX::NSManagedObjectModel.alloc.initWithContentsOfURL_(modelURL)
        return @managedObjectModel
    end

    # Returns the persistent store coordinator for the application. This
    # implementation creates and return a coordinator, having added the store
    # for the application to it. (The directory for the store is created,
    # if necessary.)
    def persistentStoreCoordinator
        if @persistentStoreCoordinator
            return @persistentStoreCoordinator
        end

        mom = self.managedObjectMode
        if !mom
            OSX.NSLog("%@:%@ No model to generate a store from", self.class, __method__)
            return nil
        end

        fileManager = NSFileManager.defaultManager
        applicationFilesDirectory = self.applicationFilesDirectory
        error = nil

        properties, error = applicationFilesDirectory.resourceValuesForKeys_error_(OSX::NSArray.arrayWithObject_(OSX::NSURLIsDirectoryKey))

        if !properties
            ok = false
            if error.code == OSX::NSFileReadNoSuchFileError
                ok, error = fileManager.createDirectoryAtPath_withIntermediateDirectories_attributes_error_(applicationFilesDirectory.path, true, nil)
            end
            if !ok
                OSX::NSApplication.sharedApplication.presentError_(error)
                return nil
            end
        else
            if properties.objectForKey_(OSX::NSURLIsDirectoryKey).boolValue != true
                # Customize and localize this error.
                failureDescription = OSX::NSString.stringWithFormat_("Expected a folder to store application data, found a file (%@).", applicationFilesDirectory.path)

                dict = OSX::NSMutableDictionary.dictionary
                dict.setValue_forKey_(failureDescription, OSX::NSLocalizedDescriptionKey)
                error = OSX::NSError.errorWithDomain_code_userInfo_("YOUR_ERROR_DOMAIN", 101, dict)

                OSX::NSApplication.sharedApplication.presentError_(error)
                return nil
            end
        end

        url = applicationFilesDirectory.URLByAppendingPathComponent_("NmapR.storedata")
        @persistentStoreCoordinator = OSX::NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel_(mom)
        ok, error = @persistentStoreCoordinator.addPersistentStoreWithType_configuration_URL_options_error_(OSX::NSXMLStoreType, nil, url, nil)
        if !ok
            OSX::NSApplication.sharedApplication.presentError_(error)
            @persistentStoreCoordinator = nil
            return nil
        end

        return @persistentStoreCoordinator
    end

    # Returns the managed object context for the application (which is already
    # bound to the persistent store coordinator for the application.) 
    def managedObjectContext
        if @managedObjectContext
            return @managedObjectContext
        end

        coordinator = self.persistentStoreCoordinator
        if !coordinator
            dict = OSX::NSMutableDictionary.dictionary
            dict.setValue_forKey_("Failed to initialize the store", OSX::NSLocalizedDescriptionKey)
            dict.setValue_forKey_("There was an error building up the data file.", OSX::NSLocalizedFailureReasonErrorKey)
            error = NSError.errorWithDomain_code_userInfo_("YOUR_ERROR_DOMAIN", 9999, dict)
            OSX::NSApplication.sharedApplication.presentError_(error)
            return nil
        end
        @managedObjectContext = OSX::NSManagedObjectContext.alloc.init
        @managedObjectContext.setPersistentStoreCoordinator_(coordinator)

        return @managedObjectContext
    end

    def windowWillReturnUndoManager_(window)
        return self.managedObjectContext.undoManager
    end

    def saveAction_(sender)
        error = nil

        if !self.managedObjectContext.commitEditing
            OSX::NSLog("%@:%@ unable to commit editing before saving", self.class, __method__)
        end

        ok, error = self.managedObjectContext.save_
        if !ok
            OSX::NSApplication.sharedApplication.presentError_(error)
        end
    end

    def applicationShouldTerminate_(sender)

        # Save changes in the application's managed object context before the application terminates.
        if !@managedObjectContext
            return OSX::NSTerminateNow
        end

        if !self.managedObjectContext.commitEditing?
            NSLog("%@:%@ unable to commit editing to terminate", self.class, __method__)
            return OSX::NSTerminateCancel
        end

        if !self.managedObjectContext.hasChanges?
            return OSX::NSTerminateNow
        end

        ok, error = self.managedObjectContext.save_
        if ok
            result = sender.presentError(error)
            if result
                return OSX::NSTerminateCancel
            end

            question = OSX::NSLocalizedString("Could not save changes while quitting. Quit anyway?", "Quit without saves error question message")
            info = OSX::NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", "Quit without saves error question info")
            quitButton = OSX::NSLocalizedString("Quit anyway", "Quit anyway button title")
            cancelButton = OSX::NSLocalizedString("Cancel", "Cancel button title")
            alert = OSX::NSAlert.alloc.init
            alert.setMessageText_(question)
            alert.setInformativeText_(info)
            alert.addButtonWithTitle_(quitButton)
            alert addButtonWithTitle_(cancelButton)

            answer = alert.runModal

            if answer == OSX::NSAlertAlternateReturn
                return OSX::NSTerminateCancel
            end
        end

        return OSX::NSTerminateNow
    end

    # NSTextField delegate

    def controlTextDidChange(note)
        hosts = @host_text_field.stringValue.to_s
        prefix = @prefix_text_field
    end


    # NSTableView delegate methods
    def tableView_objectValueForTableColumn_row(sender, col, row)
        if col == @result_table.tableColumns.to_a[0]
            @result_data_source[row][0]
        else
            @result_data_source[row][1]
        end
    end

    def numberOfRowsInTableView(sender)
        @result_data_source.length
    end

    ib_action :onScan do
        OSX::NSLog("Starting scan")
        @scan_button.setTitle("Stop")
        @progress_indicator.startAnimation(self)
        @result_data_source[0][0] = "127.0.0.1"
        @result_data_source[0][1] = "22"
        # Call scan on model here
        #sleep(1.0)
        @nmap_model.scan_it()
        @result_data_source.sort! {|a,b| a[0].upcase <=> b[0].upcase }
        @result_table.reloadData
        @progress_indicator.stopAnimation(self)
        @scan_button.setTitle("Scan")
        OSX::NSLog("Scan done")
    end

    ib_action :onReset do
        OSX::NSLog("Resetting values")
    end
end

