import Foundation

enum ServerSyncJob {
    case startJob(instanceId: String, token: String)
    case refreshTokenJob(newToken: String)
    case subscribeJob(interest: String, localInterestsChanged: Bool)
    case unsubscribeJob(interest: String, localInterestsChanged: Bool)
    case setSubscriptions(interests: [String], localInterestsChanged: Bool)
    case applicationStartJob(metadata: Metadata)
    case setUserIdJob(userId: String)
    case reportEventJob(eventType: ReportEventType)
    case stopJob
}

extension ServerSyncJob: Codable {
    enum Discriminator: Int, Codable {
        case startJobKey = 0
        case refreshTokenJobKey = 1
        case subscribeJobKey = 2
        case unsubscribeJobKey = 3
        case setSubscriptionsKey = 4
        case applicationStartJobKey = 5
        case setUserIdJobKey = 6
        case reportEventJobKey = 7
        case stopJobKey = 8
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
        case parseError(reason: String)

        public var errorDescription: String? {
            switch self {
            case .parseError(let reason):
                return NSLocalizedString("Parsing error", comment: reason)
            }
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let discriminator = try container.decode(Discriminator.self, forKey: .discriminator)
        switch discriminator {
        case .startJobKey:
            let instanceId = try container.decode(String.self, forKey: .startJobInstanceIdKey)
            let token = try container.decode(String.self, forKey: .startJobTokenKey)
            self = .startJob(instanceId: instanceId, token: token)
            return

        case .refreshTokenJobKey:
            let newToken = try container.decode(String.self, forKey: .newTokenKey)
            self = .refreshTokenJob(newToken: newToken)
            return

        case .subscribeJobKey:
            let interest = try container.decode(String.self, forKey: .interestKey)
            let localInterestsChangedKey = try container.decode(Bool.self, forKey: .localInterestsChangedKey)
            self = .subscribeJob(interest: interest, localInterestsChanged: localInterestsChangedKey)
            return

        case .unsubscribeJobKey:
            let interest = try container.decode(String.self, forKey: .interestKey)
            let localInterestsChangedKey = try container.decode(Bool.self, forKey: .localInterestsChangedKey)
            self = .unsubscribeJob(interest: interest, localInterestsChanged: localInterestsChangedKey)
            return

        case .setSubscriptionsKey:
            let interests = try container.decode([String].self, forKey: .interestsKey)
            let localInterestsChangedKey = try container.decode(Bool.self, forKey: .localInterestsChangedKey)
            self = .setSubscriptions(interests: interests, localInterestsChanged: localInterestsChangedKey)
            return

        case .applicationStartJobKey:
            let metadata = try container.decode(Metadata.self, forKey: .metadataKey)
            self = .applicationStartJob(metadata: metadata)
            return

        case .setUserIdJobKey:
            let userId = try container.decode(String.self, forKey: .userIdKey)
            self = .setUserIdJob(userId: userId)
            return

        case .reportEventJobKey:
            if let openEventType = try? container.decode(OpenEventType.self, forKey: .openEventTypeKey) {
                self = .reportEventJob(eventType: openEventType)
                return
            }
            if let deliveryEventType = try? container.decode(DeliveryEventType.self, forKey: .deliveryEventTypeKey) {
                self = .reportEventJob(eventType: deliveryEventType)
                return
            }

            throw ServerSyncJobError.parseError(reason: "Issue with the report event")

        case .stopJobKey:
            self = .stopJob
            return
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let key: CodingKeys = .discriminator

        switch self {
        case .startJob(let instanceId, let token):
            let value: Discriminator = .startJobKey
            try container.encode(value, forKey: key)
            try container.encode(instanceId, forKey: .startJobInstanceIdKey)
            try container.encode(token, forKey: .startJobTokenKey)

        case .refreshTokenJob(let newToken):
            let value: Discriminator = .refreshTokenJobKey
            try container.encode(value, forKey: key)
            try container.encode(newToken, forKey: .newTokenKey)

        case .subscribeJob(let interest, let localInterestsChanged):
            let value: Discriminator = .subscribeJobKey
            try container.encode(value, forKey: key)
            try container.encode(interest, forKey: .interestKey)
            try container.encode(localInterestsChanged, forKey: .localInterestsChangedKey)

        case .unsubscribeJob(let interest, let localInterestsChanged):
            let value: Discriminator = .unsubscribeJobKey
            try container.encode(value, forKey: key)
            try container.encode(interest, forKey: .interestKey)
            try container.encode(localInterestsChanged, forKey: .localInterestsChangedKey)

        case .setSubscriptions(let interests, let localInterestsChanged):
            let value: Discriminator = .setSubscriptionsKey
            try container.encode(value, forKey: key)
            try container.encode(interests, forKey: .interestsKey)
            try container.encode(localInterestsChanged, forKey: .localInterestsChangedKey)

        case .applicationStartJob(let metadata):
            let value: Discriminator = .applicationStartJobKey
            try container.encode(value, forKey: key)
            try container.encode(metadata, forKey: .metadataKey)

        case .setUserIdJob(let userId):
            let value: Discriminator = .setUserIdJobKey
            try container.encode(value, forKey: key)
            try container.encode(userId, forKey: .userIdKey)

        case .reportEventJob(let eventType):
            let value: Discriminator = .reportEventJobKey
            try container.encode(value, forKey: key)
            if let openEventType = eventType as? OpenEventType {
                try container.encode(openEventType, forKey: .openEventTypeKey)
            }
            if let deliveryEventType = eventType as? DeliveryEventType {
                try container.encode(deliveryEventType, forKey: .deliveryEventTypeKey)
            }

        case .stopJob:
            let value: Discriminator = .stopJobKey
            try container.encode(value, forKey: key)
        }
    }
}
