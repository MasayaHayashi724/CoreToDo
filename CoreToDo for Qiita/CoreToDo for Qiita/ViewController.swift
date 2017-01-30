//
//  ViewController.swift
//  CoreToDo for Qiita
//
//  Created by Masaya Hayashi on 2017/01/28.
//  Copyright © 2017年 Masaya Hayashi. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Global Properties

var taskCategories:[String] = ["ToDo", "Shopping", "Assignment"]

// MARK: - class ViewController

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties

    @IBOutlet weak var taskTableView: UITableView!
    
    // MARK: -
    
    private let segueEditTaskViewController = "SegueEditTaskViewController"
    
    // MARK: - Properties for table veiw
    
    var tasks:[Task] = []
    var tasksToShow:[String:[String]] = {
        var tasksToShow:[String:[String]] = [:]
        
        for taskCategory in taskCategories {
            tasksToShow[taskCategory] = []
        }
        
        return tasksToShow
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskTableView.dataSource = self
        taskTableView.delegate = self        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // fetch data from core data
        getData()
        
        // reload the table view
        taskTableView.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination as? AddTaskViewController else { return }
        
        // Configure View Controller
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        destinationViewController.context = context
        if let indexPath = taskTableView.indexPathForSelectedRow, segue.identifier == segueEditTaskViewController {
            let editedCategory = taskCategories[indexPath.section]
            let editedName = tasksToShow[editedCategory]?[indexPath.row]
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name = %@ and category = %@", editedName!, editedCategory)
            do {
                let task = try context.fetch(fetchRequest)
                destinationViewController.task = task[0]
            } catch {
                print("Fetching Failed.")
            }
        }
    }
    
    // MARK: - Method of Getting data from Core Data
    
    func getData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            // fetch data from core data
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            tasks = try context.fetch(fetchRequest)
            
            // clear tasksToShow array
            for key in tasksToShow.keys {
                tasksToShow[key] = []
            }
            // put the data into tasksToShow array
            for task in tasks {
                tasksToShow[task.category!]?.append(task.name!)
            }
        } catch {
            print("Fetching Failed.")
        }
    }

    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return taskCategories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return taskCategories[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = UILabel()
        
        title.text = taskCategories[section]
        
        title.textAlignment = NSTextAlignment.center
        title.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1.0)
        title.textColor = .brown
        title.font = UIFont(name: "Helvetica Neue", size: 20.0)
        
        return title
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksToShow[taskCategories[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = taskTableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseIdentifier, for: indexPath) as? TaskTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        let sectionData = tasksToShow[taskCategories[indexPath.section]]
        let cellData = sectionData?[indexPath.row]
        
        cell.taskLabel.text = "\(cellData!)"
        cell.taskLabel.textColor = .brown
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            // fetch task you want to delete
            let deletedCategory = taskCategories[indexPath.section]
            let deletedName = tasksToShow[deletedCategory]?[indexPath.row]
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name = %@ and category = %@", deletedName!, deletedCategory)
            do {
                let task = try context.fetch(fetchRequest)
                context.delete(task[0])
            } catch {
                print("Fetching Failed.")
            }
            
            // save context
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            // fetch data from core data
            getData()
        }
        // reload table view
        taskTableView.reloadData()
    }
    
}

