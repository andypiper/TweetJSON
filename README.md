# TweetJSON

iOS app using Twitter Kit to retrieve raw Tweet JSON

### Build

- `pod install`
- Register an app at apps.twitter.com and enter consumer key and secret in Twitter.blank.plist
- Rename Twitter.blank.plist -> Twitter.plist (ensure it is included in the app bundle)
- Run!

### Usage notes

- type or paste a Tweet ID into the top field, hit Query
- calls `statuses/lookup` with the Tweet ID. 
  - Currently, the `tweet_mode=extended` option is forced. In a future version, this may be made optional.
