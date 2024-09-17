//
//  UserVisitsCall.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 1/29/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import LUX
import FunNet
import Combine
import LithoOperators
import Prelude

func getUserVisitsCall(_ serverConfig: ServerConfigurationProtocol = Current.serverConfig, userId: String? = nil) -> CombineNetCall {
    var endpoint = Endpoint()
    var path = "users"
    if let uuid = userId {
        path = "\(path)/\(uuid)/visits"
    } else {
        path = "\(path)/all_visits"
    }
    endpoint.path = path
    endpoint /> addJsonHeaders
    let call = CombineNetCall(configuration: serverConfig, endpoint)
    if serverConfig.shouldStub {
        call.firingFunc = { $0.responder?.data = userVisitsJson().data(using: .utf8) }
    }
    return call
}

func userVisitsJson() -> String {
    return """
{"visits": [
    {"time":"2019-10-11T15:57:36Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"701","route_id":"7","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-11T19:57:37Z","updated_at":"2019-10-11T19:57:37Z","id":43295125,"direction_id":1},
    {"time":"2019-10-11T15:57:34Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"701","route_id":"7X","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-11T19:57:35Z","updated_at":"2019-10-11T19:57:35Z","id":43295106,"direction_id":1},
    {"time":"2019-10-11T15:57:20Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"B04","route_id":"F","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-11T19:57:21Z","updated_at":"2019-10-11T19:57:21Z","id":43295102,"direction_id":1},
    {"time":"2019-10-11T15:56:26Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"719","route_id":"G","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-11T19:56:27Z","updated_at":"2019-10-11T19:56:27Z","id":43294988,"direction_id":1},
    {"time":"2019-10-11T15:56:22Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"719","route_id":"G","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-11T19:56:23Z","updated_at":"2019-10-11T19:56:23Z","id":43294952,"direction_id":1},
    {"time":"2019-10-11T15:56:18Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"719","route_id":"E","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-11T19:56:19Z","updated_at":"2019-10-11T19:56:19Z","id":43294936,"direction_id":1},
    {"time":"2019-10-11T15:56:15Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"719","route_id":"7X","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-11T19:56:16Z","updated_at":"2019-10-11T19:56:16Z","id":43294786,"direction_id":1},
    {"time":"2019-10-11T15:56:12Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"719","route_id":"7","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-11T19:56:13Z","updated_at":"2019-10-11T19:56:13Z","id":43294763,"direction_id":1},
    {"time":"2019-10-11T15:56:02Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"716","route_id":"7","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-11T19:56:03Z","updated_at":"2019-10-11T19:56:03Z","id":43294762,"direction_id":1},
    {"time":"2019-10-11T15:55:52Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"712","route_id":"7","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-11T19:55:53Z","updated_at":"2019-10-11T19:55:53Z","id":43294761,"direction_id":1},
    {"time":"2019-10-11T15:55:49Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"712","route_id":"7X","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-11T19:55:50Z","updated_at":"2019-10-11T19:55:50Z","id":43294759,"direction_id":0},
    {"time":"2019-10-09T19:16:28Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"B06","route_id":"F","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-09T23:16:29Z","updated_at":"2019-10-09T23:16:29Z","id":43007845,"direction_id":1},
    {"time":"2019-10-09T14:05:40Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"G09","route_id":"R","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-09T18:05:41Z","updated_at":"2019-10-09T18:05:41Z","id":42962686,"direction_id":1},
    {"time":"2019-10-09T14:05:37Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"G09","route_id":"M","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-09T18:05:37Z","updated_at":"2019-10-09T18:05:37Z","id":42962675,"direction_id":1},
    {"time":"2019-10-09T14:05:25Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"G09","route_id":"E","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-09T18:05:26Z","updated_at":"2019-10-09T18:05:26Z","id":42962601,"direction_id":0},
    {"time":"2019-10-09T14:04:39Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"D37","route_id":"Q","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-09T18:04:40Z","updated_at":"2019-10-09T18:04:40Z","id":42962348,"direction_id":0},
    {"time":"2019-10-07T22:24:39Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"229","route_id":"C","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-08T02:24:39Z","updated_at":"2019-10-08T02:24:39Z","id":42715274,"direction_id":0},
    {"time":"2019-10-07T22:24:15Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"229","route_id":"J","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-08T02:24:15Z","updated_at":"2019-10-08T02:24:15Z","id":42715273,"direction_id":0},
    {"time":"2019-10-07T22:24:11Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"229","route_id":"Z","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-08T02:24:11Z","updated_at":"2019-10-08T02:24:11Z","id":42715272,"direction_id":0},
    {"time":"2019-10-07T22:22:24Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"M01","route_id":"M","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-08T02:22:24Z","updated_at":"2019-10-08T02:22:24Z","id":42714950,"direction_id":1},
    {"time":"2019-10-07T22:21:50Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"H11","route_id":"A","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-08T02:21:50Z","updated_at":"2019-10-08T02:21:50Z","id":42714939,"direction_id":0},
    {"time":"2019-10-05T12:02:56Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"M04","route_id":"M","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-05T16:02:57Z","updated_at":"2019-10-05T16:02:57Z","id":42385434,"direction_id":0},
    {"time":"2019-10-05T12:01:02Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"H15","route_id":"H","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-05T16:01:03Z","updated_at":"2019-10-05T16:01:03Z","id":42385431,"direction_id":1},
    {"time":"2019-10-05T12:00:59Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"H15","route_id":"A","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-05T16:01:00Z","updated_at":"2019-10-05T16:01:00Z","id":42385430,"direction_id":0},
    {"time":"2019-10-05T12:00:40Z","is_auto":false,"version":"4.5.25on8.1.0","station_id":"A65","route_id":"A","identifier":"676a5a3c-5d5c-4a16-a9c0-78a3521fded7","created_at":"2019-10-05T16:00:41Z","updated_at":"2019-10-05T16:00:41Z","id":42385429,"direction_id":1}]}
"""
}
