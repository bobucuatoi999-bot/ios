import UIKit
import WebKit

class MainViewController: UIViewController {

    // MARK: - Constants
    private let targetURL = URL(string: "https://thietbi.codientubinhan.com/")!
    private let primaryColor = UIColor(red: 21/255, green: 101/255, blue: 192/255, alpha: 1)
    private let allowedHosts = ["thietbi.codientubinhan.com", "codientubinhan.com"]

    // MARK: - UI Components
    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var refreshControl: UIRefreshControl!
    private var offlineView: OfflineView!
    private var progressObserver: NSKeyValueObservation?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupWebView()
        setupProgressView()
        setupOfflineView()
        loadWebsite()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    deinit {
        progressObserver?.invalidate()
        webView.scrollView.refreshControl = nil
    }

    // MARK: - Setup

    private func setupWebView() {
        let config = WKWebViewConfiguration()

        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = .default()

        let contentController = WKUserContentController()
        config.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic

        webView.evaluateJavaScript("navigator.userAgent") { [weak self] result, _ in
            if let ua = result as? String {
                self?.webView.customUserAgent = ua + " BinhanApp/1.0"
            }
        }

        refreshControl = UIRefreshControl()
        refreshControl.tintColor = primaryColor
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl

        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        progressObserver = webView.observe(\.estimatedProgress, options: .new) { [weak self] _, change in
            guard let self = self, let progress = change.newValue else { return }
            DispatchQueue.main.async {
                self.progressView.setProgress(Float(progress), animated: true)
                self.progressView.isHidden = progress >= 1.0
            }
        }
    }

    private func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = primaryColor
        progressView.trackTintColor = .clear
        progressView.isHidden = true

        view.addSubview(progressView)
        view.bringSubviewToFront(progressView)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 3),
        ])
    }

    private func setupOfflineView() {
        offlineView = OfflineView()
        offlineView.translatesAutoresizingMaskIntoConstraints = false
        offlineView.isHidden = true
        offlineView.onRetry = { [weak self] in
            self?.retryConnection()
        }

        view.addSubview(offlineView)

        NSLayoutConstraint.activate([
            offlineView.topAnchor.constraint(equalTo: view.topAnchor),
            offlineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offlineView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offlineView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Actions

    private func loadWebsite() {
        let request = URLRequest(url: targetURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        webView.load(request)
    }

    @objc private func handleRefresh() {
        webView.reload()
    }

    private func retryConnection() {
        offlineView.isHidden = true
        webView.isHidden = false
        loadWebsite()
    }

    private func showOffline() {
        webView.isHidden = true
        offlineView.isHidden = false
        refreshControl.endRefreshing()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
}

// MARK: - WKNavigationDelegate
extension MainViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
        progressView.setProgress(0, animated: false)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
        refreshControl.endRefreshing()
        offlineView.isHidden = true
        webView.isHidden = false
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        refreshControl.endRefreshing()
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled { showOffline() }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        refreshControl.endRefreshing()
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled { showOffline() }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow); return
        }

        if url.scheme == "about" || url.scheme == "file" || url.absoluteString == "about:blank" {
            decisionHandler(.allow); return
        }

        if let host = url.host {
            for allowed in allowedHosts {
                if host == allowed || host.hasSuffix("." + allowed) {
                    decisionHandler(.allow); return
                }
            }
        }

        if url.scheme == "mailto" || url.scheme == "tel" || url.scheme == "sms" {
            UIApplication.shared.open(url)
            decisionHandler(.cancel); return
        }

        if url.scheme == "http" || url.scheme == "https" {
            UIApplication.shared.open(url)
            decisionHandler(.cancel); return
        }

        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate
extension MainViewController: WKUIDelegate {

    // File picker — guarded for iOS 18.4+
    @available(iOS 18.4, *)
    func webView(
        _ webView: WKWebView,
        runOpenPanelWith parameters: WKOpenPanelParameters,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping ([URL]?) -> Void
    ) {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        picker.allowsMultipleSelection = parameters.allowsMultipleSelection
        picker.delegate = self
        self.documentPickerCompletion = completionHandler
        present(picker, animated: true)
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel) { _ in completionHandler(false) })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
        present(alert, animated: true)
    }
}

// MARK: - Document Picker
extension MainViewController: UIDocumentPickerDelegate {

    var documentPickerCompletion: (([URL]?) -> Void)? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.docPicker) as? ([URL]?) -> Void }
        set { objc_setAssociatedObject(self, &AssociatedKeys.docPicker, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        documentPickerCompletion?(urls)
        documentPickerCompletion = nil
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        documentPickerCompletion?(nil)
        documentPickerCompletion = nil
    }
}

private struct AssociatedKeys {
    static var docPicker: UInt8 = 0
}
