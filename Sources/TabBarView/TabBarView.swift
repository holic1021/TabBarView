//
//  ContentView.swift
//  SwiftUICustomTabBar
//
//  Created by Jerry Lo on 4/19/20.
//  Copyright © 2020 Jerry Lo. All rights reserved.
//

import SwiftUI
import UIKit

public struct Tab<Content: View> {
    var iconName: String
    var label: String?
    var tag: Int
    var content: Content
}

struct TabBarItemData {
    var tag: Int
    var content: AnyView
}

struct TabBarPreferenceData {
    var tabBarBounds: Anchor<CGRect>? = nil
    var tabBarItemData: [TabBarItemData] = []
}

struct TabBarPreferenceKey: PreferenceKey {
    typealias Value = TabBarPreferenceData
    
    static var defaultValue: TabBarPreferenceData = TabBarPreferenceData()
    
    static func reduce(value: inout TabBarPreferenceData, nextValue: () -> TabBarPreferenceData) {
        if let tabBarBounds = nextValue().tabBarBounds {
            value.tabBarBounds = tabBarBounds
            print(tabBarBounds)
        }
        value.tabBarItemData.append(contentsOf: nextValue().tabBarItemData)
    }
}

public struct TabBarView: View {
    @State var selection: Int = 0
    var tabs: [Tab<AnyView>] = []
    
    private func createTabBarContentOverlay(
        _ geometry: GeometryProxy,
        _ preferences: TabBarPreferenceData) -> some View {
        let tabBarBounds = preferences.tabBarBounds != nil ? geometry[preferences.tabBarBounds!] : .zero
        let contentToDisplay = preferences.tabBarItemData.first(where: { $0.tag == self.selection }) // 2

        return ZStack {
            if contentToDisplay == nil { // 3
                Text("Empty View")
            } else {
                contentToDisplay!.content // 4
            }
        }
        .frame(
            width: geometry.size.width,
            height: geometry.size.height - tabBarBounds.size.height,
            alignment: .center)
        .position(
            x: geometry.size.width / 2,
            y: (geometry.size.height - tabBarBounds.size.height) / 2)
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                HStack (alignment: .center) {
                    ForEach(0..<self.tabs.count) { num in
                        TabBarItem(iconName: self.tabs[num].iconName,
                                   label: self.tabs[num].label,
                                   selection: self.$selection,
                                   tag: num) {
                            self.tabs[num].content
                        }
                    }
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                .background(
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color(UIColor.systemGray2))
                            .frame(width: geometry.size.width, height: 0.5)
                            .position(x: geometry.size.width/2, y: 0)
                    }
                )
                .background(Color(UIColor.systemGray6))
                .transformAnchorPreference(
                    key: TabBarPreferenceKey.self,
                    value: .bounds,
                    transform: { (
                        value: inout TabBarPreferenceData,
                        anchor: Anchor<CGRect>) in
                        value.tabBarBounds = anchor
                    }
                )
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .overlayPreferenceValue(TabBarPreferenceKey.self) { (preferences: TabBarPreferenceData) in
                    return GeometryReader { geometry in
                    self.createTabBarContentOverlay(geometry, preferences)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(tabs: [
            Tab(iconName: "star.fill",
                label: "Favorites",
                tag: 0,
                content: AnyView(Text("Favorite Contents"))
            )
        ])
    }
}
