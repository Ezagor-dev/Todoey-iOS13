import UIKit

class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let getStartedButton = UIButton(type: .custom)
    private let skipButton = UIButton(type: .custom)

    private let pages: [OnboardingPage] = [
        OnboardingPage(imageName: "scribble.variable",
                       title: "Stay Organized",
                       description: "Effortlessly manage your tasks and stay organized with AshList. Keep track of everything you need to do in one convenient place."),
        OnboardingPage(imageName: "paintpalette.fill",
                       title: "Customize Your Workflow",
                       description: "Tailor AshList to fit your unique workflow. Create categories, create items, and personalize your task management experience."),
        OnboardingPage(imageName: "dial.min.fill",
                       title: "Boost Productivity",
                       description: "Stay focused, accomplish more, and experience a sense of accomplishment as you make progress towards your targets.")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScrollView()
        setupPageControl()
        setupButtons()
    }

    private func setupScrollView() {
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false

        var pageFrame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        for (index, page) in pages.enumerated() {
            pageFrame.origin.x = scrollView.frame.width * CGFloat(index)
            let pageView = createPageView(page: page, frame: pageFrame)
            scrollView.addSubview(pageView)
        }

        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(pages.count), height: scrollView.frame.height)
        view.addSubview(scrollView)
    }

    private func createPageView(page: OnboardingPage, frame: CGRect) -> UIView {
        let pageView = UIView(frame: frame)

        let imageView = UIImageView(frame: CGRect(x: (frame.width - 100) / 2, y: 100, width: 100, height: 100))
        imageView.image = UIImage(systemName: page.imageName)
        imageView.tintColor = .black
        pageView.addSubview(imageView)

        let titleLabel = UILabel(frame: CGRect(x: 20, y: imageView.frame.maxY + 20, width: frame.width - 40, height: 30))
        titleLabel.text = page.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        pageView.addSubview(titleLabel)

        let descriptionLabel = UILabel(frame: CGRect(x: 20, y: titleLabel.frame.maxY + 20, width: frame.width - 40, height: 80))
        descriptionLabel.text = page.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .gray
        pageView.addSubview(descriptionLabel)

        return pageView
    }

    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black

        let pageControlSize = pageControl.size(forNumberOfPages: pages.count)
        let pageControlX = (view.bounds.width - pageControlSize.width) / 2
        let pageControlY = view.bounds.height - 100
        pageControl.frame = CGRect(x: pageControlX, y: pageControlY, width: pageControlSize.width, height: pageControlSize.height)
        view.addSubview(pageControl)
    }

    private func setupButtons() {
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.backgroundColor = .gray
        skipButton.layer.cornerRadius = 8
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)

        getStartedButton.setTitle("Get Started", for: .normal)
        getStartedButton.setTitleColor(.white, for: .normal)
        getStartedButton.backgroundColor = .blue
        getStartedButton.layer.cornerRadius = 8
        getStartedButton.addTarget(self, action: #selector(getStartedButtonTapped), for: .touchUpInside)
        getStartedButton.isHidden = true

        let buttonsStackView = UIStackView(arrangedSubviews: [skipButton])
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 10

        let buttonsStackViewWidth: CGFloat = 200
        let buttonsStackViewHeight: CGFloat = 50
        buttonsStackView.frame = CGRect(x: (view.bounds.width - buttonsStackViewWidth) / 2, y: view.bounds.height - 150, width: buttonsStackViewWidth, height: buttonsStackViewHeight)
        view.addSubview(buttonsStackView)
        view.addSubview(getStartedButton)
    }


    @IBAction func getStartedButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "OnboardingToCategorySegue", sender: self)
    }

    @IBAction func skipButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "OnboardingToCategorySegue", sender: self)
    }


    private func showCategoryViewController() {
        let categoryViewController = CategoryViewController()
                let navigationController = UINavigationController(rootViewController: categoryViewController)
                navigationController.modalPresentationStyle = .fullScreen
                present(navigationController, animated: true, completion: nil)
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)

        if pageControl.currentPage == pages.count - 1 {
            getStartedButton.isHidden = false
            skipButton.isHidden = false
        } else {
            getStartedButton.isHidden = true
            skipButton.isHidden = false
        }
    }

}

struct OnboardingPage {
    let imageName: String
    let title: String
    let description: String
}