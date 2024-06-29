//
//  ContactManager.swift
//  iContacts
//
//  Created by Мухаммед Каипов on 21/5/24.
//

import Foundation
struct ContactManager {
    let allContactsKey: String = "allContactsKey"
    let userDefaults: UserDefaults = UserDefaults.standard
    
    func getAllContacts() -> [Contact]{
        var allContacts: [Contact] = []
        
        if let data = userDefaults.object(forKey: allContactsKey) as? Data {
            do{
                let decoder = JSONDecoder()
                allContacts = try decoder.decode([Contact].self, from: data)
            } catch {
                print("could'n decode given data to [Contact] with error: \(error.localizedDescription)")

            }
        }
        return allContacts
    }
    
    func addContact(contact: Contact) {
        var allContacts = getAllContacts()
        allContacts.append(contact)
        save(allContacts: allContacts)
    }
    
    // Редактирование контакта
    func edit(contactToEdit: Contact, editedContact: Contact) {
        var allContacts = getAllContacts()
        for index in 0..<allContacts.count{
            let contact = allContacts[index]
            
            if contact.firstName == contactToEdit.firstName && contact.lastName == contactToEdit.lastName && contact.phone == contactToEdit.phone {
                // Удаляем из массива allContacts старый контакт по индексу
                allContacts.remove(at: index)
                // Добавляем новый, отредактрованный контакт в массив под индексом
                allContacts.insert(editedContact, at: index)
                
                // ключевое слово break выводит чтение кода из цикла. Почему именно здесь? Потому что здесь мы уже нашли нужный нам контакт и заменили на новый, и дальше нет смысла пробегаться по остальным контактам в массиве allContacts.
                break
            }
        }
        save(allContacts: allContacts)
    }
    
    // Удаление выбранного контакта
    func delete(contactToDelete: Contact){
        var allContacts = getAllContacts()
        for index in 0..<allContacts.count{
            let contact = allContacts[index]

            if contact.firstName == contactToDelete.firstName && contact.lastName == contactToDelete.lastName && contact.phone == contactToDelete.phone{
                allContacts.remove(at: index)
                break
            }
        }
        save(allContacts: allContacts)
    }
    
    /// Записывает массив из Contact в UserDefaults

    func save(allContacts: [Contact]) {
        do{
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(allContacts)
            
            userDefaults.set(encodedData, forKey: allContactsKey)
        }catch{
            print("Couldn't encode given [Userscore] into data with error: \(error.localizedDescription)")
        }
    }
}
