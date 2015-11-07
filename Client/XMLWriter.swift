//
//  XMLWriter.swift
//  Bankroll
//
//  Created by AD Mohanraj on 6/26/15.
//  Copyright (c) 2015 AD. All rights reserved.
//

import Foundation

//Convert this class to use native Swift strings rather than NSStrings
class XMLWriter {
    private var xmlString : NSString!
    private var tagsToBeClosed : [NSString]!
    private var groupElements : [NSString]!
    
    init() {
        xmlString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        tagsToBeClosed = [NSString]()
        groupElements = [NSString]()
    }
    
    //Appends elements to an array so they can all be added under another element later
    func addElementToGroup(elementName: NSString, content: NSString) {
        groupElements.append("\t\(openTag(elementName))\(content)\(closeTag(elementName))")
    }
    
    //Clears the elements stored in the group
    func clearGroup() {
        groupElements.removeAll(keepCapacity: false)
    }
    
    //Creates an element that contains all the elements in group
    func createElementThatEncapsulatesGroup(elementName: NSString) {
        beginElementTag(elementName)
        for element in groupElements {
            addContent("\n\(element)")
        }
        endElementTag(elementName)
        clearGroup()
    }
    
    func getXMLString() -> NSString {
        return xmlString
    }
    
    private func openTag(elementName: NSString) -> NSString {
        return "<\(elementName)>"
    }
    
    private func closeTag(elementName: NSString) -> NSString {
        return "</\(elementName)>"
    }
    
    private func beginElementTag(elementName: NSString) {
        xmlString = "\(xmlString)\n<\(elementName)>"
        tagsToBeClosed.append(elementName)
    }
    
    private func addContent(content: NSString) {
        xmlString = "\(xmlString)\(content)"
    }
    
    private func endElementTag(elementName: NSString) {
        if tagsToBeClosed.removeLast() == elementName {
            xmlString = "\(xmlString)\n</\(elementName)>"
        }
        else {
            println("Cannot close tag yet. Maybe you forgot to close the child tags first.")
        }
    }
}