//
//  ViewController.swift
//  NamesToFaces
//
//  Created by Rodrigo Cavalcanti on 30/04/24.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell.")
        }
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true // This dictionary parameter will contain always contain .editedImage because allowsEditing is true. Otherwise, it would contain the key .originalImage
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        picker.delegate = self // Useful for telling us when the user either selected a picture or cancelled the picker.
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) { // UIImage has a jpegData() to convert it to a Data object in JPEG image format
            try? jpegData.write(to: imagePath) // There's a method on Data called write(to:) that, well, writes its data to disk.
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        // All apps that are installed have a directory called Documents where you can save private information for the app, and it's also automatically synchronized with iCloud
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) // The first parameter asks for the documents directory, and its second parameter adds that we want the path to be relative to the user's home directory.  This returns an array that nearly always contains only one thing: the user's documents directory.
        return path[0]
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        let ac = UIAlertController(title: "Selection an Action", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {[weak self, weak person] _ in
            guard let self, let person else { return }
            self.deletePerson(person)
        }
        ac.addAction(deleteAction)
        
        let renameAction = UIAlertAction(title: "Rename", style: .default) {[weak self, weak person] _ in
            guard let self, let person else { return }
            self.renamePerson(person)
        }
        ac.addAction(renameAction)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func renamePerson(_ person: Person) {
        let renameAc = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        renameAc.addTextField()
        
        renameAc.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        renameAc.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak renameAc] _ in
            guard let newName = renameAc?.textFields?[0].text else { return }
            person.name = newName
            
            self?.collectionView.reloadData()
        }))
        
        present(renameAc, animated: true)
    }
    
    func deletePerson(_ person: Person) {
        let deleteAc = UIAlertController(title: "Confirm deletion", message: nil, preferredStyle: .alert)
        
        deleteAc.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        deleteAc.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            people.removeAll {
                $0.name == person.name && $0.image == person.image
            }
            collectionView.reloadData()
        })
        
        present(deleteAc, animated: true)
    }
}

