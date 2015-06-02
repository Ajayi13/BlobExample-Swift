//
//  ViewController.swift
//  BlobExampleSwift
//
//  Created by Ajay Ghodadra on 02/06/15.
//  Copyright (c) 2015 Ajay Ghodadra. All rights reserved.
//

import UIKit

class ViewController: UIViewController,CloudStorageClientDelegate {
    
    var credential: AuthenticationCredential!
    var client: CloudStorageClient!
    var container: NSArray!
    var blobArray: NSArray!
    
    override func viewDidLoad() {
        
        credential = AuthenticationCredential(azureServiceAccount:"container name",accessKey:"access key")
        client = CloudStorageClient(credential:credential)
        client.delegate = self
        
        
        client.getBlobContainersWithBlock { (containers , error) -> Void in
            if ((error) != nil){
             println(error.localizedDescription)
            }else{
               println(containers.count)
               println("containers were found…")
                if (containers.count != 0){
                   self.container = NSArray.arrayByAddingObject(containers) as? NSArray
                }
            }
        }
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func getBlob(sender: AnyObject) {
        // get all blobs within a container
        client.getBlobs(self.container.objectAtIndex(0) as! BlobContainer) { (blobs, error) -> Void in
            if ((error) != nil){
                println(error.localizedDescription)
            }else{
                println(blobs.count)
                println("containers were found…")
                if (blobs.count != 0){
                    self.blobArray = NSArray.arrayByAddingObject(blobs) as? NSArray
                }
                
                for var i = 0; i<self.blobArray.count; i++ {
                    println(self.blobArray.objectAtIndex(i))
                }
            }
        }
    }
   
    @IBAction func addBlob(sender: AnyObject) {
        var image: UIImage = UIImage(named:"image.png")!
        var imageData: NSData = UIImagePNGRepresentation(image)
        var boundary = "random string of your choosing"
        var contentType = "multipart/form-data; boundary=" + boundary
        client.addBlobToContainer(self.container.objectAtIndex(0) as! BlobContainer, blobName: "image1.png", contentData: imageData, contentType: contentType)
    }
    
    @IBAction func deleteBlob(sender: AnyObject) {
        client.deleteBlob(blobArray.objectAtIndex(blobArray.count-3) as! Blob) { (error) -> Void in
            if ((error) != nil){
                println(error.localizedDescription)
            }else{
                println("Deleted Sucessfully...")
            }
        }
    }
    
    func storageClient(client: CloudStorageClient!, didAddBlobToContainer container: BlobContainer!, blobName: String!) {
        var imageUrl :NSString = "http://container_name.blob.core.windows.net/table_name/" + blobName
        println(imageUrl)
    }
    
}

