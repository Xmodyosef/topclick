# Background Operations

Login items, launch agents, and background task management for macOS apps.

## Login Items (Modern)

Use the ServiceManagement framework to register your app as a login item.

### Register as Login Item

```swift
import ServiceManagement

func enableLoginItem() throws {
    try SMAppService.mainApp.register()
}

func disableLoginItem() throws {
    try SMAppService.mainApp.unregister()
}

func isLoginItemEnabled() -> Bool {
    SMAppService.mainApp.status == .enabled
}
```

### SwiftUI Settings Toggle

```swift
struct GeneralSettingsView: View {
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        Form {
            Toggle("Launch at Login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    do {
                        if newValue {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        // Revert toggle on failure
                        launchAtLogin = SMAppService.mainApp.status == .enabled
                    }
                }
        }
    }
}
```

### Login Item Status

```swift
switch SMAppService.mainApp.status {
case .notRegistered:
    print("Not registered as login item")
case .enabled:
    print("Will launch at login")
case .requiresApproval:
    print("User needs to approve in System Settings > General > Login Items")
case .notFound:
    print("App not found")
@unknown default:
    break
}
```

## Launch Agents (Advanced)

For helper tools that run independently of the main app. The helper registers as a launch agent via ServiceManagement.

### Helper Tool Setup

1. Create a new target for the helper (Command Line Tool or App)
2. Embed it in the main app's bundle under `Contents/Library/LoginItems/`
3. Register via ServiceManagement

```swift
// In the main app
let helperService = SMAppService.agent(plistName: "com.example.myapp.helper.plist")

func installHelper() throws {
    try helperService.register()
}

func removeHelper() throws {
    try helperService.unregister()
}
```

### Launch Agent Plist

Place in the helper's bundle or the app's `Contents/Library/LaunchAgents/`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.myapp.helper</string>
    <key>BundleProgram</key>
    <string>Contents/Library/LoginItems/MyHelper.app/Contents/MacOS/MyHelper</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
</dict>
</plist>
```

## Background Tasks in Sandboxed Apps

### Not BGTaskScheduler

❌ `BGTaskScheduler` / `BGAppRefreshTask` in a native Mac app — the BackgroundTasks API is
`API_UNAVAILABLE(macos)` (it exists only for iOS, iPadOS, tvOS, and Mac Catalyst).
✅ Native macOS: schedule deferrable work with `NSBackgroundActivityScheduler` (below), and keep the
app awake for in-progress work with `ProcessInfo.beginActivity`.

### ProcessInfo for Extended Runtime

Keep the app alive for critical work when the user switches away:

```swift
func performCriticalWork() async {
    let activity = ProcessInfo.processInfo.beginActivity(
        options: [.userInitiated, .idleSystemSleepDisabled],
        reason: "Processing export"
    )

    defer { ProcessInfo.processInfo.endActivity(activity) }

    // This work continues even if the user switches to another app
    await exportLargeFile()
}
```

### NSBackgroundActivityScheduler

For periodic background work (macOS 10.10+):

```swift
class BackgroundScheduler {
    private var activity: NSBackgroundActivityScheduler?

    func startPeriodicSync() {
        activity = NSBackgroundActivityScheduler(identifier: "com.example.myapp.sync")
        activity?.repeats = true
        activity?.interval = 30 * 60  // 30 minutes
        activity?.tolerance = 5 * 60  // 5 minute tolerance
        activity?.qualityOfService = .utility

        activity?.schedule { completion in
            Task {
                do {
                    try await self.performSync()
                    completion(.finished)
                } catch {
                    completion(.deferred)  // Try again later
                }
            }
        }
    }

    func stopPeriodicSync() {
        activity?.invalidate()
        activity = nil
    }
}
```

## File System Monitoring

Watch for file changes using DispatchSource:

```swift
class FileWatcher {
    private var source: DispatchSourceFileSystemObject?
    private var fileDescriptor: Int32 = -1

    func watch(url: URL, events: DispatchSource.FileSystemEvent = [.write, .delete, .rename],
               handler: @escaping () -> Void) {
        fileDescriptor = open(url.path, O_EVTONLY)
        guard fileDescriptor >= 0 else { return }

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: events,
            queue: .main
        )

        source?.setEventHandler {
            handler()
        }

        source?.setCancelHandler { [weak self] in
            if let fd = self?.fileDescriptor, fd >= 0 {
                close(fd)
            }
        }

        source?.resume()
    }

    func stop() {
        source?.cancel()
        source = nil
    }

    deinit { stop() }
}

// Usage
let watcher = FileWatcher()
watcher.watch(url: configFileURL) {
    print("Config file changed, reloading...")
    reloadConfig()
}
```

### Directory Monitoring with FSEvents

For watching entire directory trees:

```swift
class DirectoryWatcher {
    private var stream: FSEventStreamRef?

    func watch(paths: [String], handler: @escaping ([String]) -> Void) {
        let callback: FSEventStreamCallback = { _, clientCallBackInfo, numEvents, eventPaths, _, _ in
            let handler = Unmanaged<WatcherBox>.fromOpaque(clientCallBackInfo!).takeUnretainedValue()
            let paths = Unmanaged<CFArray>.fromOpaque(eventPaths).takeUnretainedValue() as! [String]
            handler.handler(paths)
        }

        let box = WatcherBox(handler: handler)
        var context = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passRetained(box).toOpaque(),
            retain: nil, release: nil, copyDescription: nil
        )

        stream = FSEventStreamCreate(
            nil, callback, &context,
            paths as CFArray,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            1.0,  // Latency in seconds
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        )

        FSEventStreamScheduleWithRunLoop(stream!, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        FSEventStreamStart(stream!)
    }

    func stop() {
        if let stream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
        }
        stream = nil
    }

    class WatcherBox {
        let handler: ([String]) -> Void
        init(handler: @escaping ([String]) -> Void) { self.handler = handler }
    }
}
```

## Preventing System Sleep

```swift
// Prevent display sleep during presentations/exports
import IOKit.pwr_mgt

class SleepPreventer {
    private var assertionID: IOPMAssertionID = 0
    private var isActive = false

    func preventSleep(reason: String) {
        guard !isActive else { return }
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason as CFString,
            &assertionID
        )
        isActive = (result == kIOReturnSuccess)
    }

    func allowSleep() {
        guard isActive else { return }
        IOPMAssertionRelease(assertionID)
        isActive = false
    }

    deinit { allowSleep() }
}
```

## Best Practices

1. **Use SMAppService for login items** - Not the deprecated `SMLoginItemSetEnabled`
2. **Use NSBackgroundActivityScheduler for periodic work** - System-managed, power efficient (BGTaskScheduler is iOS-only)
3. **Use ProcessInfo activities for critical work** - Prevents suspension during exports
4. **Always clean up watchers and timers** - Cancel in deinit or when no longer needed
5. **Be power-conscious** - Use appropriate QoS levels, respect system power state
6. **Test background behavior** - Use a short `interval` and `tolerance` in debug builds rather than waiting on the real schedule
