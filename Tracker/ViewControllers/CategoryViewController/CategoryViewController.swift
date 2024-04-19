import UIKit

final class CategoryViewController: UIViewController {
    //MARK: - Delegate
    weak var delegate: CategoryViewControllerDelegate?
    //MARK: - Private Propeties
    private var categories: [String] = []
    private var selectedCategory: String = ""
    private let categoryStore = TrackerCategoryStore.shared
    //MARK: - UI
    private var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .ypWhite
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stubImageView: UIImageView = {
        let image = UIImage(named: "StubImage")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно \nобъединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryTableView: UITableView = {
        var tableView = UITableView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        view.backgroundColor = .ypWhite
        updateCategoriesList()
        showOrHideEmptyLabels()
    }
    //MARK: - Private Metods
    private func showOrHideEmptyLabels() {
        if !categories.isEmpty {
            stubLabel.isHidden = true
            stubImageView.isHidden = true
            categoryTableView.isHidden = false
        } else {
            categoryTableView.isHidden = true
            stubLabel.isHidden = false
            stubImageView.isHidden = false
        }
    }
    private func updateCategoriesList() {
        do {
            categories = try categoryStore.getListCategoriesCoreData()
        }
        catch {
            //TODO: Alert
        }
    }
    
    private func setupConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        //Текстовая картинка в центре главного экрана
        constraints.append(stubImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor))
        constraints.append(stubImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor))
        constraints.append(stubImageView.heightAnchor.constraint(equalToConstant: 80))
        constraints.append(stubImageView.widthAnchor.constraint(equalToConstant: 80))
        
        //Текстовая заглушка в центре главного экрана
        constraints.append(stubLabel.centerXAnchor.constraint(equalTo: stubImageView.centerXAnchor))
        constraints.append(stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8))
        constraints.append(stubLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16))
        constraints.append(stubLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16))
        
        constraints.append(titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38))
        
        constraints.append(categoryTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16))
        constraints.append(categoryTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16))
        constraints.append(categoryTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38))
        constraints.append(categoryTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor))
        
        constraints.append(addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        constraints.append(addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        constraints.append(addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        
        constraints.append(addCategoryButton.heightAnchor.constraint(equalToConstant: 60))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(addCategoryButton)
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
        view.addSubview(categoryTableView)
    }
    //MARK: - Objc Metods
    @objc private func addCategoryButtonClicked() {
        let viewController = CreateNewCategoryViewController()
        viewController.delegate = self
        self.present(viewController, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell",
            for: indexPath)
                as? UITableViewCell
        else {
            assertionFailure("Не удалось выполнить приведение к UITableViewCell")
            return UITableViewCell()
        }
        cell.textLabel?.text = categories[indexPath.row]
        cell.selectionStyle = .none
        cell.backgroundColor = .ypBackground
        cell.layer.masksToBounds = true
        return cell
    }
}
//MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryView != .none {
            selectedCategory = ""
        } else {
            selectedCategory = cell?.textLabel?.text ?? ""
        }
        delegate?.didSelectCategory(category: selectedCategory)
        self.dismiss(animated: true)
    }
}

// MARK: - CategoriesViewControllerProtocol:
extension CategoryViewController: NewCategoryViewControllerProtocol {
    func reloadTable() {
        do {
            categories = try categoryStore.getListCategoriesCoreData()
        }
        catch {
            //TODO: Alert
        }
        showOrHideEmptyLabels()
        categoryTableView.reloadData()
    }
}
