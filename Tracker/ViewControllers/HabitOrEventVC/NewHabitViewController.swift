import UIKit

final class NewHabitViewController: UIViewController {
    
    //MARK: - Delegate
    weak var scheduleViewControllerDelegate: ScheduleViewControllerDelegate?
    weak var trackerCreateViewControllerDelegate: TrackerCreateViewControllerDelegate?
    
    //MARK: - Private Properties
    private var selectWeekDays: [Weekday] = []
    private var configure: Array<SettingOptions> = []
    
    //MARK: - UI
    private var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var restrictionLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .ypRed
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTrackerTextField: UITextField = {
        var textField = UITextField()
        textField.backgroundColor = .ypBackground
        textField.textColor = .ypBlack
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.layer.cornerRadius = 16
        textField.delegate = self
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var clearTextFieldButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "clear_icon"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(clearTextFieldButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var categoryOrScheduleTableView: UITableView = {
        var tableView = UITableView(frame: .zero)
        tableView.register(SettingsHabitOrEventCell.self, forCellReuseIdentifier: SettingsHabitOrEventCell.cellIdentifer)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var cancelButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.backgroundColor = .ypWhite
        button.tintColor = .ypRed
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var createButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = .ypGray
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var buttonStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appendSettingsToArray()
        view.backgroundColor = .ypWhite
        setupView()
        setupConstraints()
        categoryOrScheduleTableView.delegate = self
        categoryOrScheduleTableView.dataSource = self
        self.addTapGestureToHideKeyboard()
    }
    
    //MARK: - Private Methods
    private func setupConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38))
        
        constraints.append(nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75))
        constraints.append(nameTrackerTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16))
        constraints.append(nameTrackerTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16))
        constraints.append(nameTrackerTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38))
        
        constraints.append(categoryOrScheduleTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16))
        constraints.append(categoryOrScheduleTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16))
        constraints.append(categoryOrScheduleTableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24))
        constraints.append(categoryOrScheduleTableView.heightAnchor.constraint(equalToConstant: 150))
        
        constraints.append(buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        constraints.append(buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        constraints.append(buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        
        constraints.append(cancelButton.heightAnchor.constraint(equalToConstant: 60))
        constraints.append(createButton.heightAnchor.constraint(equalToConstant: 60))
        
        constraints.append(restrictionLabel.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 8))
        constraints.append(restrictionLabel.leftAnchor.constraint(equalTo: nameTrackerTextField.leftAnchor, constant: 28))
        constraints.append(restrictionLabel.rightAnchor.constraint(equalTo: nameTrackerTextField.rightAnchor, constant: -28))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(nameTrackerTextField)
        view.addSubview(restrictionLabel)
        view.addSubview(categoryOrScheduleTableView)
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
    }
    
    private func appendSettingsToArray() {
        configure.append(
            SettingOptions(
                name: "Категория",
                pickedSettings: "Mocks" //TODO
            ))
        configure.append(SettingOptions(
            name: "Расписание",
            pickedSettings: nil
        ))
    }
    
    private func checkCorrectness() {
        if let text = nameTrackerTextField.text, !text.isEmpty || !selectWeekDays.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
    //MARK: - Objc Methods
    @objc func cancelButtonClicked() {
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    @objc private func clearTextFieldButtonClicked() {
        nameTrackerTextField.text = ""
        clearTextFieldButton.isHidden = true
    }
    
    @objc func createButtonClicked() {
        guard let text = nameTrackerTextField.text, !text.isEmpty else { return }
        let newTracker = Tracker(id: UUID(),
                                 name: text,
                                 color: .ypColorSelection7,
                                 emoji: "👻",
                                 schedule: self.selectWeekDays)
        self.dismiss(animated: true)
        trackerCreateViewControllerDelegate?.passingTracker(newTracker, "Mocks", from: self)
    }
    
    @objc private func textFieldDidChange() {
        if let text = nameTrackerTextField.text, !text.isEmpty {
            clearTextFieldButton.isHidden = false
        } else {
            clearTextFieldButton.isHidden = true
        }
        if nameTrackerTextField.text!.count >= 38 {
            restrictionLabel.isHidden = false
        } else {
            restrictionLabel.isHidden = true
        }
        checkCorrectness()
    }
}

// MARK: - UITextFieldDelegate
extension NewHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource
extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsHabitOrEventCell.cellIdentifer, for: indexPath) as? SettingsHabitOrEventCell else {
            assertionFailure("Не удалось выполнить приведение к SettingsHabitOrEventCell")
            return UITableViewCell()
        }
        cell.textLabel?.text = configure[indexPath.row].name
        cell.detailTextLabel?.text = configure[indexPath.row].pickedSettings
        cell.backgroundColor = .ypBackground
        return cell
    }
}
// MARK: - UITableViewDelegate
extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let viewController = CategoryViewController()
            self.present(viewController, animated: true)
        } else if indexPath.row == 1 {
            let viewController = ScheduleViewController()
            viewController.delegate = self
            self.scheduleViewControllerDelegate?.didSelectDays(self.selectWeekDays)
            self.present(viewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        checkCorrectness()
    }
}
// MARK: - ScheduleViewControllerDelegate
extension NewHabitViewController: ScheduleViewControllerDelegate {
    func didSelectDays(_ days: [Weekday]) {
        selectWeekDays = days
        let schedule = days.isEmpty ? "" : days.map { $0.shortDayName }.joined(separator: ", ")
        configure[1].pickedSettings = schedule
        categoryOrScheduleTableView.reloadData()
        dismiss(animated: true)
    }
}
