//
//  ContentView.swift
//  VK-OAuth2
//
//  Created by Кристина Перегудова on 01.11.2021.
//

import SwiftUI
import WebKit

struct ContentView: View {
  @State private var showWebView = false
  @ObservedObject var viewModel = ContentViewModel()
  
  var body: some View {
    VStack(alignment: .center, spacing: 20) {
      Button("Sign in via VK") {
        showWebView.toggle()
      }
      Text("\(viewModel.token)")
        .frame(maxWidth: .infinity)
    }.padding()
      .sheet(isPresented: $showWebView) {
        WebView(request: URLRequest(url: URL(string: viewModel.url)!),
                viewModel: viewModel)
      }
      .onAppear {
        viewModel.onFinish = {
          showWebView = false
        }
      }
  }
}

class ContentViewModel: NSObject, ObservableObject, WKNavigationDelegate {
  @Published var token: String = ""
  @Published var url: String = ""
  @Published var onFinish: (() -> ())?
  private var clientId = "use your client_id"
  
  override init() {
    self.url = "https://oauth.vk.com/authorize?client_id=\(clientId)&display=mobile&redirect_uri=https://oauth.vk.com/blank.html&scope=offline&response_type=token&v=5.131&state=123456&revoke=1"
  }
  
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
    if let url = navigationAction.request.url?.absoluteString {
      if url.contains("access_token") {
        let parts: [String] = url.split(separator: "%").map { String($0) }
        if let index: Int = parts.firstIndex(where: { $0.contains("access_token") }),
           parts.count > index + 1 {
          self.token = parts[index + 1]
          onFinish?()
        }
      }
      decisionHandler(.allow)
    }
  }
}

struct WebView: UIViewRepresentable {
  let request: URLRequest
  let viewModel: ContentViewModel
  
  func makeUIView(context: Context) -> WKWebView  {
    let webView = WKWebView()
    webView.navigationDelegate = viewModel
    return webView
  }
  
  func updateUIView(_ uiView: WKWebView, context: Context) {
    uiView.load(request)
  }
}
