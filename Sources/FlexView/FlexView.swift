// The Swift Programming Language
// https://docs.swift.org/swift-book

//  FlexView.swift
//  SliderViewSwiftUI
//
//  Created by Cosas on 12/31/24.
//


import SwiftUI

// MARK: - SplitDirection

/// Determines the direction of the split: horizontal (side-by-side) or vertical (top-and-bottom).
enum SplitDirection {
    case horizontal
    case vertical
}

// MARK: - FlexView

struct FlexView: View {
    // MARK: - Configuration Struct
    
    /// Configuration options for FlexView.
    struct Configuration {
        var splitDirection: SplitDirection = .horizontal
        var innerPadding: CGFloat = 0
        var showsCrosshair: Bool = true
        var crosshairView: AnyView? = nil
        /// Orientation for three children layout.
        let secondaryOrientation: Bool = false
        /// Minimum size (in points) for each region (width for horizontal, height for vertical).
        let minSplitSize: CGFloat = 40
        
        let snapToFactor: CGFloat = 20
        
        let snapAnimationSpeed: CGFloat = 0.000
        
        var animation: Animation? {
            snapAnimationSpeed > 0
            ? .linear(duration: snapAnimationSpeed)
            : nil
        }
        
    }
    
    // MARK: - Inputs
    
    /// Up to four child views.
    let children: [AnyView]
    
    /// The externally controlled split ratio for this FlexView (0.0...1.0).
    @Binding var ratio: CGFloat
    
    /// A secondary ratio for nested FlexViews (0.0...1.0).
    @Binding var childRatio: CGFloat
    
    @Binding var isDragging: Bool
    
    /// Configuration for the FlexView.
    let configuration: Configuration
    
    // MARK: - Constants / Constraints
    
    // Automatically pick the child orientation: opposite of this FlexView’s orientation
    private var childSplitDirection: SplitDirection {
        configuration.splitDirection == .horizontal ? .vertical : .horizontal
    }
    
    // MARK: - Body
    
    var body: some View {
        
        GeometryReader { geo in
            Group {
                ZStack {
                    
                    // 1) Layout the child views based on how many we have
                    switch children.count {
                    case 0:
                        EmptyView()
                        
                    case 1:
                        if children.indices.contains(0) {
                            children[0]
                        }
                    case 2:
                        primaryLayout(geo: geo)
                            .animation(configuration.animation, value: ratio)
                        
                    case 3:
                        primaryLayoutWithNestedFlexView(geo: geo)
                            .animation(configuration.animation, value: ratio)
                        
                    case 4:
                        primaryLayoutWithFourChildren(geo: geo)
                            .animation(configuration.animation, value: ratio)
                        
                    default:
                        Text("FlexView currently supports up to four children.")
                            .foregroundColor(.red)
                    }
                    
                    // 2) Conditionally show the crosshair (draggable handle) if this is the parent
                    if configuration.showsCrosshair {
                        crosshair(in: geo.size)
                            .animation(configuration.animation, value: ratio)
                            .accessibilityElement()
                            .accessibilityLabel("Adjustable Handle")
                            .accessibilityHint("Drag to resize the panels")
                            .accessibilityAddTraits(.allowsDirectInteraction)
                            .accessibilityValue("\(Int(ratio * 100)) percent")
                    }
                }
            }
        }
    }
    
    // MARK: - Primary Layout for Up to Two Children
    
    @ViewBuilder
    private func primaryLayout(geo: GeometryProxy) -> some View {
        switch configuration.splitDirection {
        case .horizontal:
            // Side-by-side layout
            HStack(spacing: 0) {
                if children.indices.contains(0) {
                    children[0]
                        .frame(width: (geo.size.width * ratio) - configuration.innerPadding / 2)
                }
                Spacer(minLength: configuration.innerPadding)
                if children.indices.contains(1) {
                    children[1]
                        .frame(width: (geo.size.width * (1 - ratio)) - configuration.innerPadding / 2)
                }
            }
        case .vertical:
            // Top-and-bottom layout
            VStack(spacing: 0) {
                if children.indices.contains(0) {
                    children[0]
                        .frame(height: (geo.size.height * ratio) - configuration.innerPadding / 2)
                }
                Spacer(minLength: configuration.innerPadding)
                if children.indices.contains(1) {
                    children[1]
                        .frame(height: (geo.size.height * (1 - ratio)) - configuration.innerPadding / 2)
                }
            }
        }
    }
    
    // MARK: - Layout with Nested FlexView for Three Children
    
    @ViewBuilder
    private func primaryLayoutWithNestedFlexView(geo: GeometryProxy) -> some View {
        switch configuration.splitDirection {
        case .horizontal:
            if configuration.secondaryOrientation {
                // Nested FlexView is on the leading side
                HStack(spacing: 0) {
                    FlexView(
                        children: Array(children.prefix(2)),
                        ratio: $childRatio,
                        childRatio: .constant(0.5),
                        isDragging: .constant(false),
                        configuration: Configuration(
                            splitDirection: childSplitDirection,
                            innerPadding: configuration.innerPadding,
                            showsCrosshair: false,
                            crosshairView: nil
                        )
                    )
                    .frame(width: (geo.size.width * ratio) - configuration.innerPadding / 2)
                    
                    Spacer(minLength: configuration.innerPadding)
                    
                    if children.indices.contains(2) {
                        children[2]
                            .frame(width: (geo.size.width * (1 - ratio)) - configuration.innerPadding / 2)
                    }
                }
            } else {
                // Nested FlexView is on the trailing side
                HStack(spacing: 0) {
                    if children.indices.contains(0) {
                        children[0]
                            .frame(width: (geo.size.width * (1 - ratio)) - configuration.innerPadding / 2)
                    }
                    
                    Spacer(minLength: configuration.innerPadding)
                    
                    FlexView(
                        children: Array(children.suffix(2)),
                        ratio: $childRatio,
                        childRatio: .constant(0.5),
                        isDragging: .constant(false),
                        configuration: Configuration(
                            splitDirection: childSplitDirection,
                            innerPadding: configuration.innerPadding,
                            showsCrosshair: false,
                            crosshairView: nil
                        )
                    )
                    .frame(width: (geo.size.width * ratio) - configuration.innerPadding / 2)
                }
            }
            
        case .vertical:
            if configuration.secondaryOrientation {
                // Nested FlexView is on the top side
                VStack(spacing: 0) {
                    FlexView(
                        children: Array(children.prefix(2)),
                        ratio: $childRatio,
                        childRatio: .constant(0.5),
                        isDragging: .constant(false),
                        configuration: Configuration(
                            splitDirection: childSplitDirection,
                            innerPadding: configuration.innerPadding,
                            showsCrosshair: false,
                            crosshairView: nil
                        )
                    )
                    .frame(height: geo.size.height * ratio)
                    
                    Spacer(minLength: configuration.innerPadding)
                    
                    if children.indices.contains(2) {
                        children[2]
                            .frame(height: geo.size.height * (1 - ratio))
                    }
                }
            } else {
                // Nested FlexView is on the bottom side
                VStack(spacing: 0) {
                    if children.indices.contains(0) {
                        children[0]
                            .frame(height: geo.size.height * (1 - ratio))
                    }
                    
                    Spacer(minLength: configuration.innerPadding)
                    
                    FlexView(
                        children: Array(children.suffix(2)),
                        ratio: $childRatio,
                        childRatio: .constant(0.5),
                        isDragging: .constant(false),
                        configuration: Configuration(
                            splitDirection: childSplitDirection,
                            innerPadding: configuration.innerPadding,
                            showsCrosshair: false,
                            crosshairView: nil
                        )
                    )
                    .frame(height: geo.size.height * ratio)
                }
            }
        }
    }
    
    // MARK: - Layout with Four Children
    
    @ViewBuilder
    private func primaryLayoutWithFourChildren(geo: GeometryProxy) -> some View {
        switch configuration.splitDirection {
        case .horizontal:
            // Split horizontally into left side (two children) and right side (two children)
            HStack(spacing: 0) {
                FlexView(
                    children: Array(children[0...1]),
                    ratio: $childRatio,
                    childRatio: .constant(0.5),
                    isDragging: .constant(false),
                    configuration: Configuration(
                        splitDirection: childSplitDirection,
                        innerPadding: configuration.innerPadding,
                        showsCrosshair: false,
                        crosshairView: nil
                    )
                )
                .frame(width: (geo.size.width * ratio) - configuration.innerPadding / 2)
                
                Spacer(minLength: configuration.innerPadding)
                
                FlexView(
                    children: Array(children[2...3]),
                    ratio: $childRatio,
                    childRatio: .constant(0.5),
                    isDragging: .constant(false),
                    configuration: Configuration(
                        splitDirection: childSplitDirection,
                        innerPadding: configuration.innerPadding,
                        showsCrosshair: false,
                        crosshairView: nil
                    )
                )
                .frame(width: (geo.size.width * (1 - ratio)) - configuration.innerPadding / 2)
            }
            
        case .vertical:
            // Split vertically into top side (two children) and bottom side (two children)
            VStack(spacing: 0) {
                FlexView(
                    children: Array(children[0...1]),
                    ratio: $childRatio,
                    childRatio: .constant(0.5),
                    isDragging: .constant(false),
                    configuration: Configuration(
                        splitDirection: childSplitDirection,
                        innerPadding: configuration.innerPadding,
                        showsCrosshair: false,
                        crosshairView: nil
                    )
                )
                .frame(height: (geo.size.height * ratio) - configuration.innerPadding / 2)
                
                Spacer(minLength: configuration.innerPadding)
                
                FlexView(
                    children: Array(children[2...3]),
                    ratio: $childRatio,
                    childRatio: .constant(0.5),
                    isDragging: .constant(false),
                    configuration: Configuration(
                        splitDirection: childSplitDirection,
                        innerPadding: configuration.innerPadding,
                        showsCrosshair: false,
                        crosshairView: nil
                    )
                )
                .frame(height: (geo.size.height * (1 - ratio)) - configuration.innerPadding / 2)
            }
        }
    }
    
    // MARK: - Crosshair (Draggable Handle)
    
    private func crosshair(in containerSize: CGSize) -> some View {
        let position = calculateCrosshairPosition(containerSize: containerSize)
        
        let crossHairReturnView = Group {
            if configuration.crosshairView == nil {
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    .shadow(radius: 2)
            } else {
                configuration.crosshairView!
            }
        }
            .frame(width: 44, height: 44)
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let (newRatio, newChildRatio) = calculateNewRatios(value: value, containerSize: containerSize)
                        ratio = newRatio
                        childRatio = newChildRatio
//                        withAnimation(.easeInOut(duration: 6.5)) {
                            isDragging = true
//                        }
                    }
                    .onEnded{_ in
//                        withAnimation(.easeInOut(duration: 6.5)) {
                            isDragging = false
//                        }
                    }
            )
        
        return AnyView(
            crossHairReturnView
        )
    }
    
    // MARK: - Helper Functions
    
    /// Calculates the crosshair's position based on splitDirection and configuration.secondaryOrientation.
    private func calculateCrosshairPosition(containerSize: CGSize) -> CGPoint {
        let xPos: CGFloat
        let yPos: CGFloat
        
        switch configuration.splitDirection {
        case .horizontal:
            xPos = configuration.secondaryOrientation ? (ratio * containerSize.width) : ((1 - ratio) * containerSize.width)
            yPos = childRatio * containerSize.height
        case .vertical:
            yPos = configuration.secondaryOrientation ? (ratio * containerSize.height) : ((1 - ratio) * containerSize.height)
            xPos = childRatio * containerSize.width
        }
        
        return CGPoint(x: xPos, y: yPos)
    }
    
    /// Calculates new ratios based on the drag gesture and split orientation.
    private func calculateNewRatios(value: DragGesture.Value, containerSize: CGSize) -> (CGFloat, CGFloat) {
        let snapTo:CGFloat = configuration.snapToFactor == 0 ? 1 : configuration.snapToFactor
        let xLoc = round(value.location.x / snapTo) * snapTo
        let yLoc = round(value.location.y / snapTo) * snapTo
        var newRatio: CGFloat = ratio
        var newChildRatio: CGFloat = childRatio
        
        switch configuration.splitDirection {
        case .horizontal:
            if configuration.splitDirection == .horizontal && configuration.secondaryOrientation {
                // Nested FlexView is on the leading side
                let newParentRatio = xLoc / containerSize.width
                newRatio = clampRatio(newParentRatio, in: containerSize.width)
            } else {
                // Nested FlexView is on the trailing side
                let newParentRatio = (containerSize.width - xLoc) / containerSize.width
                newRatio = clampRatio(newParentRatio, in: containerSize.width)
            }
            newChildRatio = clampRatio(yLoc / containerSize.height, in: containerSize.height)
            
        case .vertical:
            if configuration.splitDirection == .vertical && configuration.secondaryOrientation {
                // Nested FlexView is on the top side
                let newParentRatio = yLoc / containerSize.height
                newRatio = clampRatio(newParentRatio, in: containerSize.height)
            } else {
                // Nested FlexView is on the bottom side
                let newParentRatio = (containerSize.height - yLoc) / containerSize.height
                newRatio = clampRatio(newParentRatio, in: containerSize.height)
            }
            newChildRatio = clampRatio(xLoc / containerSize.width, in: containerSize.width)
        }
        
        return (newRatio, newChildRatio)
    }
    
    // MARK: - Clamping
    
    /// Clamps the ratio so that neither side is smaller than `minSplitSize`.
    private func clampRatio(_ proposed: CGFloat, in dimension: CGFloat) -> CGFloat {
        let minRatio = configuration.minSplitSize / dimension
        let maxRatio = 1.0 - minRatio
        return proposed.clamped(to: minRatio...maxRatio)
    }
}

// MARK: - Clamping Helper

fileprivate extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// MARK: - Preview

struct FlexView_Previews: PreviewProvider {
    @State static var ratio: CGFloat = 0.5
    @State static var childRatio: CGFloat = 0.5
    static let cornerRadius: CGFloat = 3
    
    static var previews: some View {
        VStack(spacing: 20) {
            // Horizontal parent => vertical child splits with configuration.secondaryOrientation = true
            FlexView(
                children: [
                    AnyView(Color.red.cornerRadius(cornerRadius)),
                    AnyView(Color.blue.cornerRadius(cornerRadius)),
                ],
                ratio: $ratio,
                childRatio: $childRatio,
                isDragging: .constant(false),
                configuration: .init(splitDirection: .horizontal,
                                     innerPadding: 5.0,
                                     showsCrosshair: true,
                                     crosshairView: nil)
            )
            .frame(width: 300, height: 200)
            .border(Color.black)
            
            // Horizontal parent => vertical child splits with three children and configuration.secondaryOrientation = true
            FlexView(
                children: [
                    AnyView(Color.red.cornerRadius(cornerRadius)),
                    AnyView(Color.blue.cornerRadius(cornerRadius)),
                    AnyView(Color.yellow.cornerRadius(cornerRadius))
                ],
                ratio: $ratio,
                childRatio: $childRatio,
                isDragging: .constant(false),
                configuration: .init(splitDirection: .horizontal,
                                     innerPadding: 5.0,
                                     showsCrosshair: true,
                                     crosshairView: nil)
            )
            .frame(width: 300, height: 200)
            .border(Color.black)
            
            // Vertical parent => horizontal child splits with four children
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
                configuration: .init(splitDirection: .vertical,
                                     innerPadding: 5.0,
                                     showsCrosshair: true,
                                     crosshairView: nil)
            )
            .frame(width: 300, height: 300)
            .border(Color.black)
        }
        .padding()
    }
}
