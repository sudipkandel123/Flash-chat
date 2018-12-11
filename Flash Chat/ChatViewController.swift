//
//  ViewController.swift
//  Flash Chat

import UIKit
import Firebase
import ChameleonFramework


class ChatViewController: UIViewController, UITableViewDataSource ,UITableViewDelegate , UITextFieldDelegate
{
    
    // Declare instance variables here
    
    var messageArray:[Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var messageTableView: UITableView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        
        //TODO: Set yourself as the delegate of the text field here:

        messageTextfield.delegate = self
        
        //TODO: Set the tapGesture here:
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        
        //TODO: Register your MessageCell.xib file here:
        
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        messageTableView.separatorStyle = .none

        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell //dequeReusablecell allows to maintain flexibility in the table view by maintaining
        cell.messageBody.text = messageArray[indexPath.row].messageBody//the cell will take the messagebody.text value from the message array from the message.swift file and store accordingly
        cell.senderUsername.text = messageArray[indexPath.row].sender //takes the username and displays on the tableview with each message
        cell.avatarImageView.image = UIImage(named: "egg")//fot displaying the image for each user
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String!{
            //if the username match with the console username ie my username then the color will be changed to blue
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            
        }
        else{
            //for the alternate use red
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cell //return the cell condition
    }
    
    //TODO: Declare numberOfRowsInSection here:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count //count the total number of message section in the tableview and return it
    }
    
    //TODO: Declare tableViewTapped here:
    
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
        //when the table view is tapped then the editing of the textfield should be stopped
    }
    
    //TODO: Declare configureTableView here:
    //set the dimension of the tableview
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 140.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    //animation when keyboard gets down
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5)
            {
            self.heightConstraint.constant = 50 // 50+height of keyboard = 258 =308 ,, 50 is the height of the textfield
        self.view.layoutIfNeeded() //if layout updates are pending ie redraw the view
    }
    }
    
    
    //TODO: Declare textFieldDidEndEditing here:
    //animation when keyboar pops up
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        
        //TODO: Send the message to Firebase and save it in our database
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        //create a database for message database
        let messageDB = Database.database().reference().child("Messages") //when send button is pressed we are creating a database inside the main database called messages
        let messageDictionary = ["Sender" : Auth.auth().currentUser?.email,"MessageBody":messageTextfield.text!]
        messageDB.childByAutoId().setValue(messageDictionary){
            (error,ref)in
            if error != nil
            {
                print(error!)
                
            }
            else{
                print("message saved successfully")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
        //we are creating a unique value key inside the database where child database is created
        
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages(){
        let MessageDB = Database.database().reference().child("Messages") //retrieve message from the database and send to messageDB
        MessageDB.observe(.childAdded, with: { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary <String,String>
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            let message = Message()
            message.messageBody = text
            message.sender = sender
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData() // this will let user to view messages that are sent before
            })
    }
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        
        do{
            try Auth.auth().signOut()
        }
        catch{
            print("Error detected during logout")
        }
         guard(navigationController?.popToRootViewController(animated: true)) != nil
            else{
                print("No view controller pop up")
                return
        }
        
        
    }
    


}
