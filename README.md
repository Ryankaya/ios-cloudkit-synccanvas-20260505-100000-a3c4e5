# SyncCanvas — CloudKit Real-Time Sync Demo

A production-quality SwiftUI iOS app demonstrating **CloudKit** for seamless, real-time data synchronisation across all of a user's devices. Items created on iPhone are instantly available on iPad (and vice versa) through Apple's private iCloud infrastructure — no backend required.

## Feature Highlights

| CloudKit API | What it does in this app |
|---|---|
| `CKContainer` | Connects to the `iCloud.com.ryankaya.synccanvas` private container |
| `CKDatabase` (private) | Stores all canvas items in the user's personal iCloud space |
| `CKRecord` | Each canvas item is a typed record with title, content, category, colour, pin state |
| `CKQuery` + `NSPredicate` | Fetches records with sort and per-category filter predicates |
| `CKQuerySubscription` | Registers a push-based subscription so all devices receive live updates without polling |
| `CKAccountStatus` | Detects iCloud sign-in state; surfaces actionable UI for every status case |
| Conflict resolution | Fetches the latest server version before saving to avoid `serverRecordChanged` errors |

## Architecture

Strict **MVVM**:

```
SyncCanvas/
├── Models/
│   ├── CanvasItem.swift        — Value type bridging CKRecord ↔ Swift struct
│   ├── ItemCategory.swift      — Enum: note, idea, task, bookmark, quote
│   └── CloudKitError.swift     — Typed errors with retry semantics
├── ViewModels/
│   ├── CanvasViewModel.swift   — @MainActor ObservableObject; all CloudKit I/O
│   └── ItemEditorViewModel.swift — Create/edit form state
└── Views/
    ├── CanvasView.swift        — Grid + list modes, search, category filter
    ├── ItemCardView.swift      — Coloured gradient card with category icon
    ├── ItemEditorView.swift    — Form sheet for new/edit
    ├── StatsView.swift         — Per-category breakdown, recent activity
    ├── AccountStatusView.swift — iCloud status dashboard
    └── Components/
        ├── CategoryChip.swift  — Filter pill with count badge
        ├── ItemRowView.swift   — List row variant
        └── SyncIndicator.swift — Live sync dot / spinner in nav bar
```

## Setup Requirements

1. An Apple Developer account with iCloud enabled.
2. Register a CloudKit container named `iCloud.com.ryankaya.synccanvas` in [CloudKit Dashboard](https://icloud.developer.apple.com/).
3. Add your Development Team ID to `project.yml` (`DEVELOPMENT_TEAM: "XXXXXXXXXX"`), then run `xcodegen generate`.
4. Build and run on a device signed into iCloud.
5. In CloudKit Dashboard, create a `CanvasItem` record type with fields: `title (String)`, `content (String)`, `category (String)`, `colorHex (String)`, `isPinned (Int64)`.

## Apple Documentation

- [CloudKit — Apple Developer](https://developer.apple.com/documentation/cloudkit)
- [CKQuerySubscription — Subscribing to record changes](https://developer.apple.com/documentation/cloudkit/ckquerysubscription)
- [Handling CloudKit errors](https://developer.apple.com/documentation/cloudkit/handling_an_icloud_account_status_change)
- [CKRecord — Storing and Retrieving Records](https://developer.apple.com/documentation/cloudkit/ckrecord)
