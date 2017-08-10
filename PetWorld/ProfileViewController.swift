//
//  ProfileViewController.swift
//  PetWorld
//
//  Created by my mac on 4/10/17.
//  Copyright © 2017 GangsterSwagMuffins. All rights reserved.
//

import UIKit
import Parse


class ProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PetFieldsLoadedDelegate {
    
    var pet: Pet?
    var shouldShowEditButton: Bool = true
    
    @IBOutlet var profileView: ProfileView!
    
    @IBOutlet weak var headerView: HeaderView!
    
    
    var tableViewController: AboutMeTableViewController?
    
    var myPostsViewController: MyPostViewController?
    
    var presentViewController: ProfileViewInfoTabBarController?
    
    var dismissCallback: (()->())!
    
    
    
    @IBAction func editProfileButtonTapped(_ sender: Any) {
        //Code to open edit profile view controller
        
        self.performSegue(withIdentifier:
            "EditProfile", sender: nil)
        print("editProfileButtonPressed")
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Depends on whether or not came from choosing the profile tab or clicking on someone else's profile
        self.profileView.showEdit = shouldShowEditButton
        self.profileView.editButton.backgroundColor = ColorPalette.primary
        self.headerView.color = ColorPalette.primary
        
        self.headerView.titleText.textColor = UIColor.white
        self.headerView.onRightClickCallBack = {
            self.onFollowTapped()
        }
        
      //  self.profileView.followButton.tintColor = UIColor.white
        
        self.headerView.leftButton.tintColor = UIColor.white
        
        
//        if let gestures = self.profileView.containerView.gestureRecognizers{
//            for gesture in gestures{
//                if gesture is UITapGestureRecognizer{
//                    let gesture = gesture as! UITapGestureRecognizer
//                    gesture.cancelsTouchesInView = false
//                }
//                
//            }
//        }
        self.headerView.onClickCallBack = {
            self.dismiss(animated: true, completion: {
                print("Profile dismissed!")
            })
        }
      //  updateOwnerField()
        //Have an instance of delegate from app del
        
        if (shouldShowEditButton){
            
            if (Pet.getPets().count > 0){
                print("number of pets > 0")
                //Get the current pet
                self.pet = Pet.currentPet()
                //Automatically updates the UI after finished loading...
                
                self.profileView.pet = self.pet!
                if let pet = self.pet{
                    self.profileView.loadProfileImage(pet: pet)
                    self.profileView.updateUI(pet: pet)
                }
                
                self.headerView.leftButton.isHidden = true
                
                
                
            }else{ // If no pets were loaded....
                print("getPets() has <= 0")

            }
        }
       
        
        
        if let pet = self.pet{
            self.profileView.updatePetUI(pet: pet)
        }
        
        
         let storyBoard = UIStoryboard(name: "Main", bundle: nil)
         self.presentViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileViewInfoTabBarController") as! ProfileViewInfoTabBarController
        
        
        
        self.presentViewController?.cellTappedCallBack = {
            (post: Post) in
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let homeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            homeViewController.posts =  [post]
            homeViewController.isDetailView = true
            
            self.present(homeViewController, animated: true, completion: { 
                print("Presented view controller")
            })
        
        }
       self.presentViewController?.pet = self.pet
        self.presentViewController?.view.frame = self.profileView.containerView.bounds
        self.profileView.containerView.addSubview((self.presentViewController?.view)!)
    
        
    }
    
    override func viewWillAppear(_ animatee3d: Bool) {
        //Have an instance of delegate from app del
        let currentUser = User.current()!
        self.initFollowButton()

        
        
        if (shouldShowEditButton){
            if (self.pet == nil){
                if (Pet.getPets().count > 0){
                    //Get the current pet
                    self.pet = Pet.currentPet()
                    if let pet = self.pet{
                        self.profileView.loadProfileImage(pet: pet)
                    }
                    self.headerView.leftButton.isHidden = true

                }else{ // If no pets were loaded....
                    print("getPets() has <= 0")

                }
                
                
            }
        }else{
            
        
        }
       
       
        
        if let pet = self.pet{
            self.profileView.pet = pet
            if let name = pet.name{
                self.headerView.titleText.text = name
            }
          //  print(pet)
           
        }
          self.tableViewController?.pet = self.pet
        
        if let pet = self.pet{
              self.tableViewController?.updateUI(pet: pet)
            self.tableViewController?.tableView.reloadData()
            
        }
       
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapLogOut(_ sender: Any) {
        
        let refreshAlert = UIAlertController(title: "Log Out", message: "Are you sure you want to Log Out of PetWorld?", preferredStyle: UIAlertControllerStyle.alert);
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil));
        
        refreshAlert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (action: UIAlertAction!) in
            
            User.logOutInBackground()
            //change view controller to login view controller
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(viewController!, animated: true, completion: nil)
 
        }));
        
        present(refreshAlert, animated: true, completion: nil);
    }

    
    func petFieldsLoaded(){
        
        if let pet = self.pet{
              self.profileView.updatePetUI(pet: (self.pet!))
              self.tableViewController?.updateUI(pet: pet)
              self.tableViewController?.tableView.reloadData()
        }
      
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "picEditor" {
            let dVc = segue.destination as! ProfilePictureEditorViewController
            dVc.user = User.current()
            dVc.pet = self.pet
        }
    }
    
    func onFollowTapped() {
        let isFollowing = self.headerView.rightButton.isSelected
        
        let currentPet = Pet.currentPet()!
        
        
        
        if isFollowing == true{
            if let pet = self.pet{
                self.headerView.rightButton.isSelected = false
                
                NetworkAPI.unfollow(follower: currentPet, followee: pet, completionHandler: {
                    print("Successful unfollow!")
                }, errorHandler: { (error: Error) in
                    print("Problem unfollowing!!!")
                })
            }
          
            
        }else{
            
            if let pet = self.pet{
                self.headerView.rightButton.isSelected = true
                
                NetworkAPI.follow(follower: currentPet, followee: pet, completionHandler: {
                    print("Successful follow.")
                }, errorHandler: { (error: Error) in
                    print("Unsuccessful follow.")
                })
            }
           
            
        }
        
        
        
        
    }
    
    func initFollowButton(){
        self.headerView.rightButton.tintColor = UIColor.white
        if (!shouldShowEditButton){
            self.headerView.rightButton.isHidden = false
            
        }else{
            self.headerView.rightButton.isHidden = true
        }
        self.headerView.rightButton.setTitle("Follow", for: UIControlState.normal)
        self.headerView.rightButton.setTitle("Unfollow", for: UIControlState.selected)
        
        let currentPet = Pet.currentPet()
        
        if let pet = self.pet{
            let petId = pet.objectId
            
            
            //You can't follow yourself
            if pet == currentPet{
                self.headerView.rightButton.isHidden = true
                return
            }
            
            
            if let petId = petId{
                if (currentPet?.isFollowing(pet: pet))!{
                    self.headerView.rightButton.isSelected = true
                }
                
            }
        }
        
        
        
        
        
        
    }

 

}
