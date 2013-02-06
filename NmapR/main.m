//
//  main.m
//  NmapR
//
//  Created by Lars Mehrtens on 06.02.13.
//  Copyright (c) 2013 AWE13. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <RubyCocoa/RBRuntime.h>

int main(int argc, char *argv[])
{
    RBApplicationInit("rb_main.rb", argc, (const char **)argv, nil);
    return NSApplicationMain(argc, (const char **)argv);
}
