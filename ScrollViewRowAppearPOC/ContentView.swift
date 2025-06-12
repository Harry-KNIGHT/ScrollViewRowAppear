import SwiftUI

struct ContentView: View {
    @State private var visibles: [Item] = []
    let sampleItems = (0..<100).map { Item(number: $0) }
    
    var body: some View {
        
        ScrollView {
            LazyVStack(spacing: 100) {
                ForEach(sampleItems) { num in
                    Text("number: \(num.name)")
                        .padding()
                        .frame(maxWidth: UIScreen.main.bounds.width / 2)
                        .background(Color.blue)
                        .padding(.horizontal)
                        .scaleEffect(visibles.contains(num) ? 1 : 0)
                        .animation(.spring(duration: 0.85, bounce: 0.35), value: visibles.contains(num))
                        .anchorPreference(
                            key: VisibleItemsPreference.self,
                            value: .bounds,
                            transform: { anchor in
                                [Payload(item: num, bounds: anchor)]
                            })
                        .onAppear {
                            visibles.append(num)
                        }
                        
                    
                }
            }
        }
        .onChange(of: visibles, { _, newValue in
            print(newValue.map(\.name))
        })
        .backgroundPreferenceValue(VisibleItemsPreference.self) { preferences in
            GeometryReader { proxy in
                Color.clear
                    .onChange(of: preferences) { _, value in
                        let frame = proxy.frame(in: .local)
                        let visibleItems = value
                            .sorted { $0.item.number < $1.item.number }
                            .filter { payload in
                                let rect = proxy[payload.bounds]
                                return frame.intersects(rect)
                            }
                            .map { $0.item }

                        visibleItems.forEach { item in
                            if !visibles.contains(item) {
                                visibles.append(item)
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}

struct Item: Identifiable, Hashable {
    var id = UUID()
    var number: Int

    var name: String {
        "Item \(number)"
    }
}

struct Payload: Equatable {
    var item: Item
    var bounds: Anchor<CGRect>
}

struct VisibleItemsPreference: PreferenceKey {
    static var defaultValue: [Payload] = []
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}
