import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBarBorder()
        self.viewControllers = [createTrackerViewController(), createStatisticViewController()]
    }
    
    func createTrackerViewController() -> UINavigationController {
        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "TrackerItem"),
            tag: 0)
        
        return UINavigationController(rootViewController: trackerViewController)
    }
    
    func createStatisticViewController() -> UINavigationController {
        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "StatisticItem"),
            tag: 1)
        return UINavigationController(rootViewController: statisticViewController)
    }
    
    func setTabBarBorder() {
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.ypGray.cgColor
    }
}
