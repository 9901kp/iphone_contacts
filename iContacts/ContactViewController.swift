//
//  ContactViewController.swift
//  iContacts
//
//  Created by Мухаммед Каипов on 19/5/24.
//

import UIKit

protocol ContactViewControllerDelegate{
    func contactWasDeleted()
}

class ContactViewController: UIViewController {

    
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var initialsContainerView: UIView!
    @IBOutlet var initialsLabel: UILabel!
    @IBOutlet var nameSurnameLabel: UILabel!
    @IBOutlet var phoneNumberButton: UIButton!
    @IBOutlet var undoDeleteButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    @IBOutlet var messageStackView: UIStackView!
    @IBOutlet var callSatckView: UIStackView!
    @IBOutlet var videoStackView: UIStackView!
    @IBOutlet var mailStackView: UIStackView!
    @IBOutlet var phoneStackView: UIStackView!
    
    let contactManager = ContactManager()
    var contact: Contact!
    var timer: Timer?
    var countDown: Int = 0
    var countDownTotal: Int = 5
    
    var delegate: ContactViewControllerDelegate?
    var wasDeleted: ((Bool)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupContactContent()
        messageStackView.layer.cornerRadius = 5
        callSatckView.layer.cornerRadius = 5
        videoStackView.layer.cornerRadius = 5
        mailStackView.layer.cornerRadius = 5
        phoneStackView.layer.cornerRadius = 5
        undoDeleteButton.layer.cornerRadius = 5
        deleteButton.layer.cornerRadius = 5
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editContact))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        initialsContainerView.layer.cornerRadius = initialsContainerView.frame.height / 2
    }
    
    func setupContactContent(){
        initialsLabel.text = "\(contact.firstName.first!)\(contact.lastName.first!)"
        nameSurnameLabel.text = "\(contact.firstName) \(contact.lastName)"
        phoneNumberButton.setTitle(contact.phone, for: .normal)
    }
    
    @objc
    func editContact(){
        let alertController = UIAlertController(title: "Add Contact", message: nil, preferredStyle: .alert)
        alertController.addTextField{ textField in
            textField.text = self.contact.firstName
        }
        alertController.addTextField{ textField in
            textField.text = self.contact.lastName
        }
        alertController.addTextField{ textField in
            textField.text = self.contact.phone
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default){ _ in
            let firstName: String = alertController.textFields![0].text!
            let lastName: String = alertController.textFields![1].text!
            let phone: String = alertController.textFields![2].text!
            
            let editedContact = Contact(firstName: firstName, lastName: lastName, phone: phone)
            self.save(editedContact: editedContact)
        }
        alertController.addAction(saveAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController,animated: true)
    }
    
    func save(editedContact: Contact){
        contactManager.edit(contactToEdit: contact, editedContact: editedContact)
        contact = editedContact
        setupContactContent()
    }


    @IBAction func callButtonTapped(_ sender: UIButton) {
        open(contactType: .call)
    }
    @IBAction func messageBtnTapped(_ sender: UIButton) {
        open(contactType: .message)
    }
    @IBAction func videoBtnTapped(_ sender: UIButton) {
        open(contactType: .faceTime)
    }
    @IBAction func undoBtnTapped(_ sender: UIButton) {
        timer?.invalidate()
        progressView.progress = 1
        progressView.isHidden = true
        undoDeleteButton.isHidden = true
        deleteButton.isHidden = false
        
        contactManager.addContact(contact: contact)
    }
    
    
    @IBAction func deleteBtnTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Warning!", message: "Are you sure you want to delete this contact?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive){ _ in
            self.deleteContact()
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func deleteContact(){
        contactManager.delete(contactToDelete: self.contact)
        deleteButton.isHidden = true
        undoDeleteButton.isHidden = false
        progressView.progress = 1
        progressView.isHidden = false
        
        scheduleTimer()
        
    }
    
    func scheduleTimer(){
        countDown = countDownTotal
        timer = Timer.scheduledTimer(timeInterval: 1, target: self , selector: #selector(updateProgressView), userInfo: nil, repeats: true)
    }
    @objc 
    func updateProgressView(){
        countDown -= 1
        progressView.progress = Float(countDown)/Float(countDownTotal)
        if countDown == 0{
            timer?.invalidate()
            
            navigationController?.popViewController(animated: true)
//            delegate?.contactWasDeleted()
            wasDeleted?(true)
        }
    }
    func open(contactType: ContactType){
        let phone = contact.phone
        let phoneWithoutPlus = phone.replacingOccurrences(of: "+", with: "")
        let phoneWithoutSpacing = phoneWithoutPlus.replacingOccurrences(of: " ", with: "")
        let urlString: String = "\(contactType.urlScheme)" + phoneWithoutSpacing
        guard let url = URL(string: urlString) else {
            return
        }
        UIApplication.shared.open(url)

    }
    
}


enum ContactType {
    case message
    case call
    case faceTime
    
    var urlScheme: String {
        switch self {
        case .message:
            return "sms://"
        case .call:
            return "tel://"
        case .faceTime:
            return "facetime://"
        }
    }
}
