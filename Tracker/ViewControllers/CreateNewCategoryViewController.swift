import UIKit
final class CreateNewCategoryViewController: UIViewController {
    // MARK: - Delegate:
    weak var delegate: NewCategoryViewControllerProtocol?
    // MARK: - Private properties:
    private var categoryName: String = ""
    private let categoryStore = TrackerCategoryStore.shared
    //MARK: - UI
    private var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Новая категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .ypWhite
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nameTrackerTextField: UITextField = {
        var textField = UITextField()
        textField.backgroundColor = .ypBackground
        textField.textColor = .ypBlack
        textField.placeholder = "Введите название категории"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.layer.cornerRadius = 16
        textField.delegate = self
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTapGestureToHideKeyboard()
        setupView()
        setupConstraints()
        view.backgroundColor = .ypWhite
    }
    //MARK: - Private Methods
    private func setupConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38))
        
        constraints.append(nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75))
        constraints.append(nameTrackerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16))
        constraints.append(nameTrackerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16))
        constraints.append(nameTrackerTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38))
        
        constraints.append(doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
        constraints.append(doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20))
        constraints.append(doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        
        constraints.append(doneButton.heightAnchor.constraint(equalToConstant: 60))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(nameTrackerTextField)
        view.addSubview(doneButton)
    }
    //MARK: - Objc Metods
    @objc private func doneButtonClicked() {
        do {
            try categoryStore.createCategoryCoreData(with: categoryName)
        } catch {
            let alertController = UIAlertController(
                title: "Ошибка",
                message: "Ошибка при создании новой категории",
                preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
        delegate?.reloadTable()
        self.dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CreateNewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        categoryName = textField.text ?? ""
    }
}
