//
//  MasterViewController.swift
//  MyMedicalContacts
//
//  Created by Denise Bradley on 3/20/16.
//  Copyright © 2016 Denise Bradley. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class MasterViewController: UITableViewController, CNContactPickerDelegate {
    
    var detailViewController: DetailViewController? = nil
    var objects = [CNContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let addExisting = UIBarButtonItem(title: "Add Existing", style: .Plain, target: self, action: "addExistingContact")
        self.navigationItem.leftBarButtonItem = addExisting
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "insertNewObject:", name: "addNewContact", object: nil)
        self.getContacts()
    }
    
    func getContacts() {
        let store = CNContactStore()
        
        if CNContactStore.authorizationStatusForEntityType(.Contacts) == .NotDetermined {
            store.requestAccessForEntityType(.Contacts, completionHandler: { (authorized: Bool, error: NSError?) -> Void in
                if authorized {
                    self.retrieveContactsWithStore(store)
                }
            })
        } else if CNContactStore.authorizationStatusForEntityType(.Contacts) == .Authorized {
            self.retrieveContactsWithStore(store)
        }
        
    }
    
    
    static var groupName = "Medical"
    
    /// Fetches contacts from the group in the Contacts application.
    ///
    /// - returns: array of contacts
    static func getContactsFromGroup() -> [CNContact]{
        var groupContacts = [CNContact]()
        let contactStore = CNContactStore()
        
        do {
            var predicate : NSPredicate!
            let allGroups = try contactStore.groupsMatchingPredicate(nil)
            for group in allGroups {
                if (group.name == groupName) {
                    predicate = CNContact.predicateForContactsInGroupWithIdentifier(group.identifier)
                }
            }
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactOrganizationNameKey, CNContactPhoneNumbersKey, CNContactUrlAddressesKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactNoteKey, CNContactImageDataKey]
            
            if predicate != nil {
                let contacts = try contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
                
                for contact in contacts {
                    groupContacts.append(contact)
                }
            }
            
        } catch _ {
            print("Finding contacts in \(groupName) group failed.")
        }
        
        return groupContacts
    }
    
    
    func retrieveContactsWithStore(store: CNContactStore) {
        do {
            let groups = try store.groupsMatchingPredicate(nil)
            let predicate = CNContact.predicateForContactsInGroupWithIdentifier(groups[0].identifier)
            //let predicate = CNContact.predicateForContactsMatchingName("John")
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactEmailAddressesKey, CNContactPhoneNumbersKey]
            
            let contacts = try store.unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
            self.objects = contacts
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        } catch {
            print(error)
        }
    }
    
    func addExistingContact() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.presentViewController(contactPicker, animated: true, completion: nil)
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        NSNotificationCenter.defaultCenter().postNotificationName("addNewContact", object: nil, userInfo: ["contactToAdd": contact])
    }
    
    //If user is selected, add to group
    func addContactToGroup(contact: CNContactStore) {
        // 1
        let groupNameKey = "Medical"
        let groupToAdd = CNGroup()
        
        // 2
        
        // 3
        let addedToGroup = CNErrorCode(rawValue: 0)
        if (addedToGroup == nil) {
            print("Couldn't add contact to group.")
        }
        updateContactChanges()
    }
    
    func updateContactChanges() {
        // Get mutable copy of contact
        /*var mutable = contactPicker(picker: CNContactPickerViewController, didSelectContact: <#T##CNContact#>) contact.MutableCopy() as CNMutableContact;
        var newEmail = CNLabeledValue(label: CNLabelHome, value:  NSString(string: "john.appleseed@xamarin.com"));
        
        // Append new email
        var emails = NSObject[mutable.EmailAddresses.Length+1];
        mutable.EmailAddresses.CopyTo(emails,0);
        emails[mutable.EmailAddresses.Length+1] = newEmail;
        mutable.EmailAddresses = emails;
        
        // Update contact
        var store = CNContactStore();
        var saveRequest = CNSaveRequest();
        saveRequest.UpdateContact(mutable);
        
        NSError error;
        
        if (store.executeSaveRequest(saveRequest)){
            Console.WriteLine("Contact updated.");
        } else {
            Console.WriteLine("Update error: {0}", error);
        }*/
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject(sender: NSNotification) {
        if let contact = sender.userInfo?["contactToAdd"] as? CNContact {
            objects.insert(contact, atIndex: 0)
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.contactItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let contact = self.objects[indexPath.row]
        let formatter = CNContactFormatter()
        
        cell.textLabel?.text = formatter.stringFromContact(contact)
        cell.detailTextLabel?.text = ""
        for phoneNo in contact.phoneNumbers {
            if phoneNo.label == CNLabelPhoneNumberMobile {
                cell.detailTextLabel?.text = (phoneNo.value as! CNPhoneNumber).stringValue
                break
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
}

