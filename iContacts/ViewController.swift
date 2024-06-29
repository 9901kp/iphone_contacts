//
//  ViewController.swift
//  iContacts
//
//  Created by Мухаммед Каипов on 19/5/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    
    var arrayOfContactGroup: [ContactGroup] = [] {
        didSet {
            tableView.reloadData() // Обновление таблицы при изменении массива контактов
        }
    }
    
    static let userScoreKey: String = "contactsInfoKey"
    let contactManager = ContactManager()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Регистрация класса для ячейки таблицы
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: ContactTableViewCell.identifier)
        tableView.refreshControl = UIRefreshControl()
        // Таким образом отслеживается активация индикатора и вызывается метод reloadDataSource()
        tableView.refreshControl!.addTarget(self, action: #selector(reloadData), for: .valueChanged)
                
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    /// Обнаружение нажатия кнопки add
    @IBAction func addButtonTapped(_ sender: Any) {
        addContacts()
    }
    
    /// Обнаружение изменения выбранного сегмента, а именно типа сортировки
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        // Идет запрос на обновление данных по выбранному типа сортировки
        reloadData()
    }
    
     func addContacts() {
        let alertController = UIAlertController(title: "Add contact", message: "", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "First Name"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Last Name"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Phone"
            textField.keyboardType = .phonePad
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let firstName = alertController.textFields?[0].text, !firstName.isEmpty else {
                print("First Name is required")
                self.showErrorAlert(message: "First name is empty")
                return
            }
            guard let lastName = alertController.textFields?[1].text, !lastName.isEmpty else {
                print("Last Name is required")
                self.showErrorAlert(message: "Last name is empty")
                return
            }
            guard let phone = alertController.textFields?[2].text, !phone.isEmpty else {
                print("Phone is required")
                self.showErrorAlert(message: "Phone is empty")
                return
            }
            
            guard phone.isValidPhoneNumber() else {
                self.showErrorAlert(message: "Phone number is invalid")
                return
            }
            
            let contact = Contact(firstName: firstName, lastName: lastName, phone: phone)
            self.add(contact: contact)
        }
        alertController.addAction(saveAction)
        present(alertController, animated: true)
    }
    func add(contact: Contact) {
        contactManager.addContact(contact: contact)
        self.reloadData()
    }
    
    
    
    func showErrorAlert(message: String) {
        let errorAlertController = UIAlertController(title: "Error:", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Okay", style: .default)
        errorAlertController.addAction(okAction)
        
        present(errorAlertController, animated: true)
    }
    
    

    
    @objc
    func reloadData() {
        tableView.refreshControl!.beginRefreshing()
        var dictionary: [String: [Contact]] = [:]
        
        let allContacts = contactManager.getAllContacts()
        
//группировка контактов по первой букве имени или фамилии, в зависимости от выбранного сегмента в UISegmentedControl
        allContacts.forEach{contact in
            var key: String!
            if segmentControl.selectedSegmentIndex == 0{
                key = String(contact.firstName.first!)
            }else if segmentControl.selectedSegmentIndex == 1{
                key = String(contact.lastName.first!)
            }
            //Проверка, имянын же фамилиянын баш тамгасынан турган словарь или массив барбы 
            if var existingContact = dictionary[key]{
                existingContact.append(contact)
                dictionary[key] = existingContact
            }else{
                dictionary[key] = [contact]
            }
        }
        
//Сортировка секции контактов по алфавитному очереди
        
        var arrayOfcontactGroup: [ContactGroup] = []
        let alphabeticallyOrderedKeys: [String] = dictionary.keys.sorted { key1,key2 in
            return key1 < key2
        }
        alphabeticallyOrderedKeys.forEach { key in
            let contacts = dictionary[key]
            let contactGroup = ContactGroup(title: key, contacts: contacts!)
            arrayOfcontactGroup.append(contactGroup)
        }
        tableView.refreshControl!.endRefreshing()
        self.arrayOfContactGroup = arrayOfcontactGroup
    }
    
    
    func getContact(indexPath: IndexPath) -> Contact {
        let contactGroup = arrayOfContactGroup[indexPath.section]
        let contact = contactGroup.contacts[indexPath.row]
        return contact
    }
    
    
    func deleteContact(indexPath: IndexPath) {
        let deletedContact = arrayOfContactGroup[indexPath.section].contacts.remove(at: indexPath.row)
        if arrayOfContactGroup[indexPath.section].contacts.count < 1 {
            arrayOfContactGroup.remove(at: indexPath.section)
        }
        contactManager.delete(contactToDelete: deletedContact)
    }
}









// Реализация UITableViewDataSource и UITableViewDelegate
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayOfContactGroup.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfContactGroup[section].contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier, for: indexPath) as! ContactTableViewCell
        let contact = getContact(indexPath: indexPath)

        if segmentControl.selectedSegmentIndex == 0 {
            cell.contactsTextLabel.text = "\(contact.firstName) \(contact.lastName)"
        }else if segmentControl.selectedSegmentIndex == 1 {
            cell.contactsTextLabel.text = "\(contact.lastName) \(contact.firstName)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arrayOfContactGroup[section].title
    }
    
    
    //Swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteContact(indexPath: indexPath)
        }
    }
    

}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contact = getContact(indexPath: indexPath)
        let contactViewController = ContactViewController()
        contactViewController.contact = contact
//        contactViewController.delegate = self
        contactViewController.wasDeleted = { wasReallyDeleted in
            if wasReallyDeleted{
                self.reloadData()
            }
        }
        navigationController?.pushViewController(contactViewController, animated: true)
    }
}
extension ViewController: ContactViewControllerDelegate{
    func contactWasDeleted() {
        reloadData()
    }
    
    
}


// Структура для хранения контакта
struct Contact: Codable {
    let firstName: String
    let lastName: String
    let phone: String
}

struct ContactGroup{
    let title: String
    var contacts: [Contact]
}

// Создаем РАСШИРЕНИЕ для типа данных String и добавляем функцию
extension String {
    
    // Возвращает 'true' если номер телефона валидный, 'false' в ином случае
    func isValidPhoneNumber() -> Bool {
        
        let regEx = "^\\+(?:[0-9]?){6,14}[0-9]$"
        let phoneCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        
        return phoneCheck.evaluate(with: self)
    }
}


