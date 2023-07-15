import UIKit
import AVFoundation
import AVKit

class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let getStartedButton = UIButton(type: .custom)
    private let skipButton = UIButton(type: .custom)
    

    private let pages: [OnboardingPage] = [
        OnboardingPage(videoName: "NTV3.mp4", title: "Stay Organized", description: "Effortlessly manage your tasks and stay organized with AshList. Keep track of everything you need to do in one convenient place.")
    ]
    private var playerViewController: AVPlayerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
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

            let videoURL = Bundle.main.url(forResource: "NTV3", withExtension: "mp4")!
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            pageView.addSubview(playerViewController.view)
            addChild(playerViewController)
            playerViewController.view.frame = pageView.bounds
            player.play()

            return pageView
        }

    private func setupPageControl() {
            pageControl.numberOfPages = pages.count
            pageControl.currentPage = 0
            pageControl.pageIndicatorTintColor = .lightGray
            pageControl.currentPageIndicatorTintColor = UIColor.white

            let pageControlSize = pageControl.size(forNumberOfPages: pages.count)
            let pageControlX = (view.bounds.width - pageControlSize.width) / 2
            let pageControlY = view.bounds.height - 100
            pageControl.frame = CGRect(x: pageControlX, y: pageControlY, width: pageControlSize.width, height: pageControlSize.height)
            view.addSubview(pageControl)
        }

    private func setupButtons() {
            skipButton.setTitle("Get started", for: .normal)
            skipButton.setTitleColor(.black, for: .normal)
            skipButton.backgroundColor = UIColor.white
            skipButton.layer.cornerRadius = 8
            skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
            skipButton.layer.shadowColor = UIColor.white.cgColor
            skipButton.layer.shadowOpacity = 0.7
            skipButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            skipButton.layer.shadowRadius = 4

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
            buttonsStackView.frame = CGRect(x: (view.bounds.width - buttonsStackViewWidth) / 2, y: view.bounds.height - 200, width: buttonsStackViewWidth, height: buttonsStackViewHeight)
            view.addSubview(buttonsStackView)
            view.addSubview(getStartedButton)
        }

        @objc private func getStartedButtonTapped(_ sender: UIButton) {
            OnboardingManager.shared.hasCompletedOnboarding = true
            performSegue(withIdentifier: "onboardingToCategorySegue", sender: self)
        }

        @objc private func skipButtonTapped(_ sender: UIButton) {
            OnboardingManager.shared.hasCompletedOnboarding = true
            performSegue(withIdentifier: "onboardingToCategorySegue", sender: self)
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

            if let player = playerViewController?.player {
                let currentPage = Int(pageIndex)
                let isCurrentPagePlaying = currentPage == pageControl.currentPage
                if isCurrentPagePlaying {
                    player.play()
                } else {
                    player.pause()
                }
            }

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
        let videoName: String
        let title: String
        let description: String
    }
