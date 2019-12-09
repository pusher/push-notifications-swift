import Foundation

enum ServerSyncJob {
    case StartJob(instanceId: String, token: String)
    case RefreshTokenJob(newToken: String)
    case SubscribeJob(interest: String, localInterestsChanged: Bool)
    case UnsubscribeJob(interest: String, localInterestsChanged: Bool)
    case SetSubscriptions(interests: [String], localInterestsChanged: Bool)
    case ApplicationStartJob(metadata: Metadata)
    case SetUserIdJob(userId: String)
    case ReportEventJob(eventType: ReportEventType)
    case StopJob
}

extension ServerSyncJob: Codable {
    enum Discriminator: Int, Codable {
        case StartJobKey = 0
        case RefreshTokenJobKey = 1
        case SubscribeJobKey = 2
        case UnsubscribeJobKey = 3
        case SetSubscriptionsKey = 4
        case ApplicationStartJobKey = 5
        case SetUserIdJobKey = 6
        case ReportEventJobKey = 7
        case StopJobKey = 8
    }

    enum CodingKeys: String, CodingKey {
        case discriminator
        case startJobInstanceIdKey
        case startJobTokenKey
        case newTokenKey
        case interestKey
        case localInterestsChangedKey
        case interestsKey
        case metadataKey
        case userIdKey
        case openEventTypeKey
        case deliveryEventTypeKey
    }
    
    private enum ServerSyncJobError: LocalizedError {
        case ParseError(reason: String)
        
        public var errorDescription: String? {
            switch self {
            case .ParseError(let reason):
                return NSLocalizedString("Parsing error", comment: reason)
            }
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let discriminator = try container.decode(Discriminator.self, forKey: .discriminator)
        switch discriminator {
        case .StartJobKey:
            let instanceId = try container.decode(String.self, forKey: .startJobInstanceIdKey)
            let token = try container.decode(String.self, forKey: .startJobTokenKey)
            self = .StartJob(instanceId: instanceId, token: token)
            return
        case .RefreshTokenJobKey:
            let newToken = try container.decode(String.self, forKey: .newTokenKey)
            self = .RefreshTokenJob(newToken: newToken)
            return
        case .SubscribeJobKey:
            let interest = try container.decode(String.self, forKey: .interestKey)
            let localInterestsChangedKey = try container.decode(Bool.self, forKey: .localInterestsChangedKey)
            self = .SubscribeJob(interest: interest, localInterestsChanged: localInterestsChangedKey)
            return
        case .UnsubscribeJobKey:
            let interest = try container.decode(String.self, forKey: .interestKey)
            let localInterestsChangedKey = try container.decode(Bool.self, forKey: .localInterestsChangedKey)
            self = .UnsubscribeJob(interest: interest, localInterestsChanged: localInterestsChangedKey)
            return
        case .SetSubscriptionsKey:
            let interests = try container.decode([String].self, forKey: .interestsKey)
            let localInterestsChangedKey = try container.decode(Bool.self, forKey: .localInterestsChangedKey)
            self = .SetSubscriptions(interests: interests, localInterestsChanged: localInterestsChangedKey)
            return
        case .ApplicationStartJobKey:
            let metadata = try container.decode(Metadata.self, forKey: .metadataKey)
            self = .ApplicationStartJob(metadata: metadata)
            return
        case .SetUserIdJobKey:
            let userId = try container.decode(String.self, forKey: .userIdKey)
            self = .SetUserIdJob(userId: userId)
            return
        case .ReportEventJobKey:
            if let openEventType = try? container.decode(OpenEventType.self, forKey: .openEventTypeKey) {
                self = .ReportEventJob(eventType: openEventType)
                return
            }
            if let deliveryEventType = try? container.decode(DeliveryEventType.self, forKey: .deliveryEventTypeKey) {
                self = .ReportEventJob(eventType: deliveryEventType)
                return
            }
            
            throw ServerSyncJobError.ParseError(reason: "Issue with the report event")
        case .StopJobKey:
            self = .StopJob
            return
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let k: CodingKeys = .discriminator

        switch self {
        case .StartJob(let instanceId, let token):
            let v: Discriminator = .StartJobKey
            try container.encode(v, forKey: k)
            try container.encode(instanceId, forKey: .startJobInstanceIdKey)
            try container.encode(token, forKey: .startJobTokenKey)
        case .RefreshTokenJob(let newToken):
            let v: Discriminator = .RefreshTokenJobKey
            try container.encode(v, forKey: k)
            try container.encode(newToken, forKey: .newTokenKey)
        case .SubscribeJob(let interest, let localInterestsChanged):
            let v: Discriminator = .SubscribeJobKey
            try container.encode(v, forKey: k)
            try container.encode(interest, forKey: .interestKey)
            try container.encode(localInterestsChanged, forKey: .localInterestsChangedKey)
        case .UnsubscribeJob(let interest, let localInterestsChanged):
            let v: Discriminator = .UnsubscribeJobKey
            try container.encode(v, forKey: k)
            try container.encode(interest, forKey: .interestKey)
            try container.encode(localInterestsChanged, forKey: .localInterestsChangedKey)
        case .SetSubscriptions(let interests, let localInterestsChanged):
            let v: Discriminator = .SetSubscriptionsKey
            try container.encode(v, forKey: k)
            try container.encode(interests, forKey: .interestsKey)
            try container.encode(localInterestsChanged, forKey: .localInterestsChangedKey)
        case .ApplicationStartJob(let metadata):
            let v: Discriminator = .ApplicationStartJobKey
            try container.encode(v, forKey: k)
            try container.encode(metadata, forKey: .metadataKey)
        case .SetUserIdJob(let userId):
            let v: Discriminator = .SetUserIdJobKey
            try container.encode(v, forKey: k)
            try container.encode(userId, forKey: .userIdKey)
        case .ReportEventJob(let eventType):
            let v: Discriminator = .ReportEventJobKey
            try container.encode(v, forKey: k)
            if let openEventType = eventType as? OpenEventType {
                try container.encode(openEventType, forKey: .openEventTypeKey)
            }
            if let deliveryEventType = eventType as? DeliveryEventType {
                try container.encode(deliveryEventType, forKey: .deliveryEventTypeKey)
            }
        case .StopJob:
            let v: Discriminator = .StopJobKey
            try container.encode(v, forKey: k)
        }
    }
}
