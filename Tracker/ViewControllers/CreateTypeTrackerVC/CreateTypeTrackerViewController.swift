import UIKit

final class CreateTypeTrackerViewController: UIViewController {
    
    //MARK: - Delegate
    weak var delegate: CreateTypeTrackerDelegate?
    
    //MARK: - UI
    private var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Создание трекера"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var createHabitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .ypWhite
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createNewTask), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var createIrregularEvent: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярные события", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.tintColor = .ypWhite
        button.addTarget(self, action: #selector(createNewIrregularEvent), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        view.backgroundColor = .ypWhite
    }
    
    //MARK: - Private Methods
    private func setupConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38))
        
        constraints.append(stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20))
        constraints.append(stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor))
        
        constraints.append(createHabitButton.heightAnchor.constraint(equalToConstant: 60))
        constraints.append(createIrregularEvent.heightAnchor.constraint(equalToConstant: 60))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        stackView.addArrangedSubview(createHabitButton)
        stackView.addArrangedSubview(createIrregularEvent)
    }
    
    //MARK: - Objc Methods
    @objc private func createNewTask() {
        print("create new task")
        let viewController = NewHabitViewController()
        viewController.trackerCreateViewControllerDelegate = self
        present(viewController, animated: true)
    }
    
    @objc private func createNewIrregularEvent() {
        print("Create irregular event")
        let viewController = NewEventViewController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
}

// MARK: - TrackerCreatingViewControllerDelegate:
extension CreateTypeTrackerViewController: TrackerCreateViewControllerDelegate {
    func passingTracker(_ tracker: Tracker,  _ category: String, from: UIViewController) {
        self.dismiss(animated: true)
        delegate?.plusTracker(tracker, category, from: self)
    }
}
