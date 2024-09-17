//
//  LoginWifi.swift
//  NYCSubwayLib
//
//  Created by Elliot Schrock on 4/12/21.
//  Copyright © 2021 Thryv. All rights reserved.
//

import FunNet
import LithoOperators
import Prelude
import Combine

let testPage = "http://connectivitycheck.gstatic.com/generate_204"
let bapConfig = ServerConfiguration(host: "bap.aws.opennetworkexchange.net", apiRoute: "api/v1")
let capConfig = ServerConfiguration(host: "cap.aws.opennetworkexchange.net", apiRoute: "HSO/grpfiles/153")

var wifiCancelBag = Set<AnyCancellable>()
var wifiCall: CombineNetCall?
var pingTask: URLSessionDataTask?
var pingResponder: NetworkResponderProtocol?

func followRedirect() {
    ping(URL(string: testPage)!, with: redirectResponder())
}

func ping(_ url: URL, with responder: NetworkResponderProtocol) {
    let request = URLRequest(url: url)
    let task = generateDataTask(sessionConfiguration: URLSessionConfiguration.default, request: request, responder: responder)
    task?.resume()
    pingTask = task
    pingResponder = responder
    responder.taskHandler(task)
}

func redirectResponder() -> CombineNetworkResponder {
    let responder = CombineNetworkResponder()
    responder.$httpResponse.skipNils()
        .filter(^\.statusCode >>> isGreaterThan(299))
        .filter(^\.statusCode >>> isLessThan(400))
        .map(\.allHeaderFields)
        .map(redirectUrl(from:) >?> loginParams >>> dictionaryToUrlUnencodedParams)
        .skipNils()
        .sink(receiveValue: portal).store(in: &wifiCancelBag)
    responder.$httpResponse.skipNils()
        .filter(^\.statusCode >>> isEqualTo(200))
        .map(\.allHeaderFields)
        .map(redirectUrl(from:) >?> loginParams >>> dictionaryToUrlUnencodedParams)
        .skipNils()
        .sink(receiveValue: portal).store(in: &wifiCancelBag)
    responder.$httpResponse.skipNils()
        .filter(^\.statusCode >>> isEqualTo(204))
        .sink(receiveValue: ignoreArg(sendConnectedNotification))
        .store(in: &wifiCancelBag)
    responder.$httpResponse.skipNils()
        .map(^\.statusCode)
        .sink(receiveValue: sendResponseCodeNotification)
        .store(in: &wifiCancelBag)
    responder.$httpResponse.skipNils()
        .filter(^\.statusCode >>> isEqualTo(200))
        .map(\.allHeaderFields)
        .map(redirectUrl(from:) >?> loginParams >>> dictionaryToUrlUnencodedParams)
        .skipNils()
        .sink(receiveValue: portal).store(in: &wifiCancelBag)
    responder.$httpResponse.skipNils()
        .filter(^\.statusCode >>> isEqualTo(200))
        .map(\.allHeaderFields)
        .map(redirectUrl(from:)).skipNils()
        .map(\.absoluteString)
        .sink(receiveValue: sendStringNotification).store(in: &wifiCancelBag)
    wifiCall = CombineNetCall(configuration: Current.serverConfig, Endpoint(), responder: responder)
    return responder
}

func portal(_ paramsString: String) {
    sendRedirectNotification()
    var endpoint = Endpoint()
    endpoint.path = "welcome1.html?\(paramsString)"
    wifiCall = CombineNetCall(configuration: capConfig, endpoint, responder: portalResponder(paramsString))
    wifiCall?.fire()
}

func portalResponder(_ paramsString: String) -> CombineNetworkResponder {
    let responder = CombineNetworkResponder()
    responder.$httpResponse.skipNils().sink(receiveValue: ignoreArg(paramsString *> auth(_:))).store(in: &wifiCancelBag)
    responder.$httpResponse.skipNils().map(^\.statusCode).sink(receiveValue: sendResponseCodeNotification).store(in: &wifiCancelBag)
    return responder
}

func auth(_ paramsString: String) {
    sendAuthNotification()
    var endpoint = Endpoint()
    endpoint.path = "auth?\(paramsString)"
    wifiCall = CombineNetCall(configuration: bapConfig, endpoint, responder: authResponder(paramsString))
    wifiCall?.fire()
}

func authResponder(_ paramsString: String) -> CombineNetworkResponder {
    let responder = CombineNetworkResponder()
    responder.$httpResponse.skipNils().sink(receiveValue: ignoreArg(paramsString *> login(_:))).store(in: &wifiCancelBag)
    responder.$httpResponse.skipNils().map(^\.statusCode).sink(receiveValue: sendResponseCodeNotification).store(in: &wifiCancelBag)
    return responder
}

func login(_ paramsString: String) {
    sendLoginNotification()
    var endpoint = Endpoint()
    endpoint.path = "auth/adtech"
    endpoint.httpMethod = "POST"
    endpoint.postData = paramsString.data(using: .utf8)
    endpoint.addHeaders(headers: ["Accept": "*/*", "Accept-Encoding": "gzip, deflate, br"])
    wifiCall = CombineNetCall(configuration: bapConfig, endpoint, responder: loginResponder())
    wifiCall?.fire()
}

func loginResponder() -> CombineNetworkResponder {
    let responder = CombineNetworkResponder()
    responder.$httpResponse.skipNils().sink(receiveValue: ignoreArg(sendLoggedInNotification)).store(in: &wifiCancelBag)
    responder.$httpResponse.skipNils().map(^\.statusCode).sink(receiveValue: sendResponseCodeNotification).store(in: &wifiCancelBag)
    return responder
}

func redirectUrl(from headers: [AnyHashable : Any]) -> URL? {
    return URL(string: headers["location"] as? String ?? "")
}

func loginParams(_ url: URL) -> [String: String] {
    var params: [String: String] = [:]
    URLComponents(string: url.absoluteString)?
        .queryItems?
        .filter(^\.name >>> isContainedIn(["PIP", "SID", "NASID", "VLAN"]))
        .forEach { item in
            if let value = item.value {
                params[item.name] = value
            }
        }
    return params
}

public func dictionaryToUrlUnencodedParams(dict: [String: Any]) -> String {
    var params = [String]()
    for key in dict.keys {
        if let value: Any = dict[key] {
            var valueString = "\(String(describing: value))"
            if let valueArray = value as? [AnyObject] {
                valueString = valueArray.map { "\($0)" }.joined(separator: ",")
            }
            let param = "\(key)=\(valueString)"
            params.append(param)
        }
    }
    return params.joined(separator: "&")
}
