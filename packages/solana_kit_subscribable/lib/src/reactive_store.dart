/// A callback invoked when a reactive store changes.
///
/// Kept as a shared typedef for stores that publish state/error changes
/// (for example `SlotTrackingReactiveStore`). The `ReactiveStreamStore` uses
/// its own `ReactiveStreamSubscriber` typedef with the same shape.
typedef ReactiveStoreSubscriber = void Function();
