import Foundation

/**
 Remote Notification Type provides an option to ignore Pusher initiated related features.
 Whenever you receive push notification the [handleNotification(userInfo:)](https://docs.pusher.com/beams/reference/ios#handle-notification) method should be called.
 Sometimes, these notifications are just for Pusher SDK to handle.

 *Values*

 `ShouldIgnore` It's safe to ignore Pusher initiated notification.

 `ShouldProcess` Do not ignore notification as it may contain additional data.
 */
@objc public enum RemoteNotificationType: Int {
    /**
     Ignore Pusher initiated notification.
     */
    case ShouldIgnore
    /**
     Do not ignore notification.
     */
    case ShouldProcess
}
