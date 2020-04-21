//
//  ContentView.swift
//  SwiftUICustomTabBar
//
//  Created by Jerry Lo on 4/19/20.
//  Copyright © 2020 Jerry Lo. All rights reserved.
//

import SwiftUI

struct TabBarItemPreferenceKey: PreferenceKey {
    static var defaultValue: (CGFloat, CGFloat) = (0, 0)
    
    typealias Value = (CGFloat, CGFloat)

    static func reduce(value: inout (CGFloat, CGFloat), nextValue: () -> (CGFloat, CGFloat)) {
        value = nextValue()
    }
}

struct TabBarItem<Content: View>: View {
    let iconName: String
    var label: String? = nil
    let selection: Binding<Int>
    let tag: Int
    let content: () -> Content
    
    init(iconName: String,
         label: String? = nil,
         selection: Binding<Int>,
         tag: Int,
         @ViewBuilder _ content: @escaping () -> Content) {
        self.iconName = iconName
        self.label = label
        self.selection = selection
        self.tag = tag
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: self.iconName)
                .frame(minWidth: 25, minHeight: 25)
            if self.label != nil {
                Text(self.label!)
                    .font(.caption)
            }
        }
        .padding([.top,.bottom], 5)
        .foregroundColor(Color(UIColor.systemGray))
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            self.selection.wrappedValue = self.tag
        }
        .preference(
            key: TabBarPreferenceKey.self,
            value: TabBarPreferenceData(
                tabBarItemData: [
                    TabBarItemData(
                        tag: self.tag,
                        content: AnyView(self.content())
                    )
                ]
            )
        )
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TabBarItem_Previews: PreviewProvider {
    static var previews: some View {
//        Text("what")
        TabBarItem(iconName: "clock.fill",
                         label: "ff",
                         selection: .constant(0),
                         tag: 0) {
            Text("Voicemail")
        }
        .previewLayout(.fixed(width: 80, height: 80))
    }
}
