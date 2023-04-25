//
//  HomeViewController.swift
//  Kitty
//
//  Created by phi.thai on 4/14/23.
//

import UIKit

class HomeViewController: UIViewController, UITabBarControllerDelegate {
    
    @IBOutlet weak var addNewBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    
    @IBOutlet weak var monthBtn: UIButton!
    
    let dtFormatter = DateFormatter()
    
    let filteredMonth = Date()
    
    var viewModel: HomeViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dtFormatter.dateStyle = .short
        dtFormatter.timeStyle = .none
        
        let calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: filteredMonth)
        
        monthBtn.setTitle(filteredMonth.month + ", " + String(calendarDate.year!), for: .normal)
        
        // Do any additional setup after loading the view.
        let cellNib = UINib(nibName: "CardTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "CardViewCell")
    }
    
    
    @IBAction func addNewButtonClickHandler(_ sender: Any) {
        let newViewController = AddNewViewController()
        newViewController.viewModel = viewModel
        newViewController.delegate = self
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        expenseLabel.text = "- " + String(viewModel!.getExpense())
        incomeLabel.text = String(viewModel!.getIncome())
        balanceLabel.text = String(viewModel!.getBalance())
    }
    
    @IBAction func settingOnClickButton(_ sender: Any) {
        tabBarController!.selectedIndex = 2
    }
    
    @IBAction func showCalendar(_ sender: Any) {
        let datePicker = MonthViewController()
        self.present(datePicker, animated: true)
//        datePicker.addTarget(self, action: #selector(handleDateSelection), for: .valueChanged)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel!.getFilteredHistory(date: filteredMonth).reversed().count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let history = viewModel!.getFilteredHistory(date: filteredMonth).reversed()[indexPath.row]
        // Fetch a cell of the appropriate type.
        let cell =  tableView.dequeueReusableCell(withIdentifier: "CardViewCell", for: indexPath) as! CardTableViewCell
        
        // Configure the cell’s contents.
        cell.cardLabel.text = dtFormatter.string(from: history.date)
        cell.set(value: history.items)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let array = viewModel!.getFilteredHistory(date: filteredMonth)
        if CGFloat(array.reversed()[indexPath.row].items.count * 56) > 0 {
            return CGFloat(array.reversed()[indexPath.row].items.count * 50 + 70 + 10*array.reversed()[indexPath.row].items.count)
        }
        return 60
    }
    
    
}

extension HomeViewController: AddNewDelegate {
    func addNewItem() {
//        expenseLabel.text = "- " + String(viewModel!.getExpense())
//        incomeLabel.text = String(viewModel!.getIncome())
//        balanceLabel.text = String(viewModel!.getBalance())
        tableView.reloadData()
    }
}
