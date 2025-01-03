//
//  FlexView readme.md
//  
//
//  Created by Cosas on 1/3/25.
//


# FlexView


FlexView is a versatile and customizable SwiftUI component that allows developers to create dynamic, resizable layouts with up to four child views. Whether you're building complex dashboards, split-view interfaces, or interactive sliders, FlexView provides a seamless and intuitive way to manage and adjust your view hierarchies.

## Features

- **Flexible Splits**: Easily split your view horizontally or vertically with up to four child views.
- **Nested Splits**: Create complex layouts by nesting FlexViews for three or four child views.
- **Interactive Crosshair**: Drag to adjust split ratios dynamically, with support for custom crosshair views.
- **Snap to Factor**: Configure snapping behavior for precise adjustments.
- **Accessibility Support**: Fully accessible with descriptive labels and hints.
- **Animations**: Smooth transitions and animations for split adjustments.
- **Configuration Struct**: Encapsulate all customization options in a clean and organized manner.


FlexView is available as a Swift Package. You can integrate it into your project using Swift Package Manager (SPM).

Usage

FlexView is designed to be highly customizable and easy to integrate. Below are some common usage scenarios.

###Basic Split with Two Views

```swift
import SwiftUI
import FlexView

struct ContentView: View {
    @State private var ratio: CGFloat = 0.5
    @State private var childRatio: CGFloat = 0.5
    @State private var isDragging: Bool = false

    var body: some View {
        FlexView(
            children: [
                AnyView(Color.red),
                AnyView(Color.blue)
            ],
            ratio: $ratio,
            childRatio: $childRatio,
            isDragging: $isDragging,
            configuration: FlexView.Configuration(
                splitDirection: .horizontal,
                innerPadding: 10,
                showsCrosshair: true,
                crosshairView: nil
            )
        )
        .frame(width: 300, height: 200)
        .border(Color.black)
    }
}
```

Nested Splits with Three or Four Views
```swift
import SwiftUI
import FlexView

struct NestedSplitView: View {
    @State private var ratio: CGFloat = 0.5
    @State private var childRatio: CGFloat = 0.5
    @State private var isDragging: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            // Three Views
            FlexView(
                children: [
                    AnyView(Color.green),
                    AnyView(Color.yellow),
                    AnyView(Color.orange)
                ],
                ratio: $ratio,
                childRatio: $childRatio,
                isDragging: $isDragging,
                configuration: FlexView.Configuration(
                    splitDirection: .horizontal,
                    innerPadding: 10,
                    showsCrosshair: true,
                    secondaryOrientation: true,
                    crosshairView: nil
                )
            )
            .frame(width: 300, height: 200)
            .border(Color.black)

            // Four Views
            FlexView(
                children: [
                    AnyView(Color.purple),
                    AnyView(Color.pink),
                    AnyView(Color.gray),
                    AnyView(Color.blue)
                ],
                ratio: $ratio,
                childRatio: $childRatio,
                isDragging: $isDragging,
                configuration: FlexView.Configuration(
                    splitDirection: .vertical,
                    innerPadding: 10,
                    showsCrosshair: true,
                    crosshairView: nil
                )
            )
            .frame(width: 300, height: 300)
            .border(Color.black)
        }
    }
}
```

Customizing the Crosshair

You can provide a custom view for the crosshair handle to match your app’s design.
```swift
import SwiftUI
import FlexView

struct CustomCrosshair: View {
    var body: some View {
        Image(systemName: "arrow.up.arrow.down")
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .clipShape(Circle())
    }
}

struct ContentView: View {
    @State private var ratio: CGFloat = 0.5
    @State private var childRatio: CGFloat = 0.5
    @State private var isDragging: Bool = false

    var body: some View {
        FlexView(
            children: [
                AnyView(Color.red),
                AnyView(Color.blue)
            ],
            ratio: $ratio,
            childRatio: $childRatio,
            isDragging: $isDragging,
            configuration: FlexView.Configuration(
                splitDirection: .horizontal,
                innerPadding: 10,
                showsCrosshair: true,
                crosshairView: AnyView(CustomCrosshair())
            )
        )
        .frame(width: 300, height: 200)
        .border(Color.black)
    }
}
```

Configuration

FlexView provides a comprehensive Configuration struct to customize its behavior and appearance.
```swift
struct Configuration {
    var splitDirection: SplitDirection = .horizontal
    var innerPadding: CGFloat = 0
    var showsCrosshair: Bool = true
    var crosshairView: AnyView? = nil
    var secondaryOrientation: Bool = false
    var minSplitSize: CGFloat = 40
    var snapToFactor: CGFloat = 20
    var snapAnimationSpeed: CGFloat = 0.000

    var animation: Animation? {
        snapAnimationSpeed > 0
        ? .linear(duration: snapAnimationSpeed)
        : nil
    }
}
```

Parameters
    •    splitDirection: Determines the primary split direction of the FlexView.
    •    .horizontal: Side-by-side layout.
    •    .vertical: Top-and-bottom layout.
    •    innerPadding: The spacing between child views.
    •    showsCrosshair: Whether to display the draggable crosshair handle.
    •    crosshairView: A custom view for the crosshair handle. If nil, a default circle is used.
    •    secondaryOrientation: Orientation flag for three children layout. Determines the placement of the nested FlexView.
    •    minSplitSize: The minimum size (in points) for each split region, ensuring that no view becomes too small.
    •    snapToFactor: Determines the snapping behavior of the crosshair. The ratio will snap to the nearest multiple of this factor.
    •    snapAnimationSpeed: The duration of the snapping animation. Set to 0 to disable animation.
    •    animation: Computed property that provides an animation based on snapAnimationSpeed.

GridView Integration

FlexView integrates a GridView as a background to aid in layout visualization. The GridView draws horizontal and vertical lines based on the snapToFactor.

Example Integration

```swift
import SwiftUI
import FlexView

struct ContentView: View {
    @State private var ratio: CGFloat = 0.5
    @State private var childRatio: CGFloat = 0.5
    @State private var isDragging: Bool = false

    var body: some View {
        ZStack {
            GridView(gridSize: CGSize(width: 100, height: 100))
                .frame(width: 300, height: 200)
                .allowsHitTesting(false) // Prevent GridView from intercepting touches

            FlexView(
                children: [
                    AnyView(Color.red),
                    AnyView(Color.blue)
                ],
                ratio: $ratio,
                childRatio: $childRatio,
                isDragging: $isDragging,
                configuration: FlexView.Configuration(
                    splitDirection: .horizontal,
                    innerPadding: 10,
                    showsCrosshair: true,
                    snapToFactor: 20,
                    snapAnimationSpeed: 0.3,
                    crosshairView: nil
                )
            )
            .frame(width: 300, height: 200)
        }
        .border(Color.black)
    }
}
```

Handling Drag Events

FlexView uses a draggable crosshair to adjust split ratios. You can monitor dragging state and respond to ratio changes using bindings.

Example: Tracking Dragging State
```swift
import SwiftUI
import FlexView

struct ContentView: View {
    @State private var ratio: CGFloat = 0.5
    @State private var childRatio: CGFloat = 0.5
    @State private var isDragging: Bool = false

    var body: some View {
        VStack {
            Text(isDragging ? "Dragging..." : "Not Dragging")
                .padding()

            FlexView(
                children: [
                    AnyView(Color.green),
                    AnyView(Color.blue)
                ],
                ratio: $ratio,
                childRatio: $childRatio,
                isDragging: $isDragging,
                configuration: FlexView.Configuration(
                    splitDirection: .vertical,
                    innerPadding: 10,
                    showsCrosshair: true,
                    snapToFactor: 20,
                    snapAnimationSpeed: 0.3,
                    crosshairView: nil
                )
            )
            .frame(width: 300, height: 300)
            .border(Color.black)
        }
    }
}
```

Preview

FlexView includes a comprehensive preview setup to visualize different configurations.
```swift
struct FlexView_Previews: PreviewProvider {
    @State static var ratio: CGFloat = 0.5
    @State static var childRatio: CGFloat = 0.5
    static let cornerRadius: CGFloat = 3

    static var previews: some View {
        VStack(spacing: 20) {
            // Two Views
            FlexView(
                children: [
                    AnyView(Color.red.cornerRadius(cornerRadius)),
                    AnyView(Color.blue.cornerRadius(cornerRadius)),
                ],
                ratio: $ratio,
                childRatio: $childRatio,
                isDragging: .constant(false),
                configuration: .init(
                    splitDirection: .horizontal,
                    innerPadding: 5.0,
                    showsCrosshair: true,
                    crosshairView: nil
                )
            )
            .frame(width: 300, height: 200)
            .border(Color.black)

            // Three Views with Secondary Orientation
            FlexView(
                children: [
                    AnyView(Color.red.cornerRadius(cornerRadius)),
                    AnyView(Color.blue.cornerRadius(cornerRadius)),
                    AnyView(Color.yellow.cornerRadius(cornerRadius))
                ],
                ratio: $ratio,
                childRatio: $childRatio,
                isDragging: .constant(false),
                configuration: .init(
                    splitDirection: .horizontal,
                    innerPadding: 5.0,
                    showsCrosshair: true,
                    secondaryOrientation: true,
                    crosshairView: nil
                )
            )
            .frame(width: 300, height: 200)
            .border(Color.black)

            // Four Views
            FlexView(
                children: [
                    AnyView(Color.green.cornerRadius(cornerRadius)),
                    AnyView(Color.purple.cornerRadius(cornerRadius)),
                    AnyView(Color.gray.cornerRadius(cornerRadius)),
                    AnyView(Color.orange.cornerRadius(cornerRadius))
                ],
                ratio: $ratio,
                childRatio: $childRatio,
                isDragging: .constant(false),
                configuration: .init(
                    splitDirection: .vertical,
                    innerPadding: 5.0,
                    showsCrosshair: true,
                    crosshairView: nil
                )
            )
            .frame(width: 300, height: 300)
            .border(Color.black)
        }
    }
}
```

