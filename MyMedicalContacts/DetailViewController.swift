//
//  DetailViewController.swift
//  MyMedicalContacts
//
//  Created by Denise Bradley on 3/20/16.
//  Copyright © 2016 Denise Bradley. All rights reserved.
//

import UIKit
import Contacts
import MapKit
import CoreLocation

class DetailViewController: UIViewController {
    
    @IBOutlet weak var contactImage: UIImageView!
    
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var street: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var postalCode: UILabel!
    @IBOutlet weak var mobilePhone: UILabel!
    @IBOutlet weak var email: UILabel!
    
    
    var contactItem: CNContact? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let oldContact = self.contactItem {
            let store = CNContactStore()
            
            do {
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactImageDataKey, CNContactImageDataAvailableKey, CNContactPhoneNumbersKey]
                let contact = try store.unifiedContactWithIdentifier(oldContact.identifier, keysToFetch: keysToFetch)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if contact.imageDataAvailable {
                        if let data = contact.imageData {
                            self.contactImage.image = UIImage(data: data)
                        }
                    }
                    
                    self.fullName.text = CNContactFormatter().stringFromContact(contact)
                    
                    self.email.text = contact.emailAddresses.first?.value as? String
                    
                    if contact.isKeyAvailable(CNContactPostalAddressesKey) {
                        if let postalAddress = contact.postalAddresses.first?.value as? CNPostalAddress {
                            self.street.text = CNPostalAddressFormatter().stringFromPostalAddress(postalAddress)
                        } else {
                            self.street.text = "No Address"
                        }
                        
                    self.mobilePhone.text = ""
                    for phoneNo in contact.phoneNumbers {
                        if phoneNo.label == CNLabelPhoneNumberMobile {
                            self.mobilePhone.text = (phoneNo.value as! CNPhoneNumber).stringValue
                            break
                        }
                    }
                    
                    let postalFormatter = CNPostalAddressFormatter()
                    let postalAddress = CNMutablePostalAddress()
                    
                    var address: CNPostalAddress!
                        for item in contact.postalAddresses{
                            if item.label == CNLabelHome {
                                address = item.value as! CNPostalAddress
                            }
                        }
                        if address != nil {
                            self.street.text = "\(address.street)"
                            self.city.text = "\(address.city)"
                            self.state.text = "\(address.state)"
                            self.postalCode.text = "\(address.postalCode)"
                        }
                        
                    }
                
                })
            } catch {
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getMap(sender: AnyObject) {
        if let oldContact = self.contactItem {
            let store = CNContactStore()
            
            do {
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactImageDataKey, CNContactImageDataAvailableKey, CNContactPhoneNumbersKey]
                let contact = try store.unifiedContactWithIdentifier(oldContact.identifier, keysToFetch: keysToFetch)
        } catch {
            print(error)
        }

        
        var address: CNPostalAddress!
        for item in oldContact.postalAddresses{
            if item.label == CNLabelHome {
                address = item.value as! CNPostalAddress
            }
        }
        if address != nil {
            self.street.text = "\(address.street)"
            self.city.text = "\(address.city)"
            self.state.text = "\(address.state)"
            self.postalCode.text = "\(address.postalCode)"
        }
        
        let geoCoder = CLGeocoder()
        
        /*do {
            geoCoder.geocodeAddressString("\(address.street) \(address.city), \(address.state)",
            completionHandler:
            {(placemarks: [AnyObject]) in
                
                if placemarks.count > 0 {
                    let placemark = placemarks[0] as! CLPlacemark
                    let location = placemark.location
                    self.coords = location.coordinate
                    
                    print("\(self.coords?.latitude) \(self.coords?.longitude)")
                }
                
        })
        } catch {
            print("Geocode failed with error: \(error.localizedDescription)")
            }*/
    }
    
    
   }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! MapViewController
        //controller.mapView = address.text
        
    }

}