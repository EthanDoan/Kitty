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

    var items: [Item]
    var history: [History]
    var income: Double
    var iconArray: [String]
    var month: [String]
    var filteredMonth: Date
    
    required init?(coder: NSCoder) {
        self.items = []
        self.history = []
        self.income = 0.0
        self.iconArray = []
        self.month = []
        self.filteredMonth = Date()
        super.init(coder: coder)
    }
    
    init(items: [Item], history : [History], income: Double, iconArray: [String], month: [String], filteredMonth: Date) {
        self.items = items
        self.history = history
        self.income = income
        self.iconArray = iconArray
        self.month = month
        self.filteredMonth = filteredMonth
        super.init(nibName: nil, bundle: Bundle.main)
    }
    
    func set(items: [Item], history : [History], income: Double, iconArray: [String], month: [String], filteredMonth: Date) {
        self.items = items
        self.history = history
        self.income = income
        self.iconArray = iconArray
        self.month = month
        self.filteredMonth = filteredMonth
    }
    
    lazy var viewModel: HomeViewModel = {
        return HomeViewModel(items: items, history: history, income: income, month: month, filteredMonth: filteredMonth)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dtFormatter.dateStyle = .short
        dtFormatter.timeStyle = .none
        
        // Do any additional setup after loading the view.
        let cellNib = UINib(nibName: "CardTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "CardViewCell")
    }
    
    
    @IBAction func addNewButtonClickHandler(_ sender: Any) {
        let newViewController = AddNewViewController(items: viewModel.items, history: viewModel.history, iconArray: iconArray)

        newViewController.delegate = self
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        monthBtn.setTitle(viewModel.convertToNormalDate(), for: .normal)
        expenseLabel.text = "- " + String(viewModel.getExpense())
        incomeLabel.text = String(viewModel.getIncome())
        balanceLabel.text = String(viewModel.getBalance())
        tableView.reloadData()
    }
    
    @IBAction func settingOnClickButton(_ sender: Any) {
        tabBarController!.selectedIndex = 2
    }
    
    @IBAction func showCalendar(_ sender: Any) {
        let datePicker = MonthViewController()
        datePicker.delegate = self
        self.present(datePicker, animated: true)
    }
    
    @IBAction func rightDateOnClickHandler(_ sender: Any) {
        let year = viewModel.addAMonth()
        monthBtn.setTitle(viewModel.filteredMonth.month + ", " + String(year), for: .normal)
        tableView.reloadData()
    }
    
    @IBAction func leftDateOnClickhandler(_ sender: Any) {
        let year = viewModel.backAMonth()
        monthBtn.setTitle(viewModel.filteredMonth.month + ", " + String(year), for: .normal)
        tableView.reloadData()
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getFilteredHistory(date: viewModel.filteredMonth).reversed().count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let history = viewModel.getFilteredHistory(date: viewModel.filteredMonth).reversed()[indexPath.row]
        // Fetch a cell of the appropriate type.
        let cell =  tableView.dequeueReusableCell(withIdentifier: "CardViewCell", for: indexPath) as! CardTableViewCell
        
        // Configure the cell’s contents.
        cell.cardLabel.text = dtFormatter.string(from: history.date)
        cell.set(value: Array(history.items))

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let array = viewModel.getFilteredHistory(date: viewModel.filteredMonth)
        if CGFloat(array.reversed()[indexPath.row].items.count * 56) > 0 {
            return CGFloat(array.reversed()[indexPath.row].items.count * 50 + 70 + 10*array.reversed()[indexPath.row].items.count)
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.2, delay: 0.2*Double(indexPath.row),animations: { () -> Void in
        cell.alpha = 1

            cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
        })
    }
}

extension HomeViewController: AddNewDelegate {
    func addNewItem(newItem: Item) {
        viewModel.setCurrentMonth()
        let calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: viewModel.filteredMonth)
        monthBtn.setTitle(viewModel.filteredMonth.month + ", " + String(calendarDate.year!), for: .normal)
        if viewModel.addHistory(newItem: newItem, historyName: Date()) == true {
            if viewModel.addItem(newItem: newItem) != true {
                let alert = UIAlertController(title: "Please check your input",
                                              message: "The inputed amount have to be in Integer format and have selected a category",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    return
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        tableView.reloadData()
    }
}

extension HomeViewController: MonthViewDelegate {
    func returnMonth(month: String) {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "LLLL"  // if you need 3 letter month just use "LLL"
        if let date = df.date(from: month) {
            let monthInt = Calendar.current.component(.month, from: date)
            let components = DateComponents (calendar: Calendar.current, year: 2023, month: monthInt, day: 14)
            let date = NSCalendar.current.date(from: components)
            viewModel.setMonth(month: date!)
            monthBtn.setTitle(viewModel.filteredMonth.month + ", " + String(components.year!), for: .normal)
        }
        tableView.reloadData()
    }
}
