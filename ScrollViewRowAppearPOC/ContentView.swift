import SwiftUI

struct ContentView: View {
    @State private var visibles: [Item] = []
    let sampleItems = (0..<100).map { Item(number: $0) }
    
    var body: some View {
        
        ScrollView {
            LazyVStack {
                ForEach(sampleItems) { num in
                    Text("number: \(num.name)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .padding(.horizontal)
                        .anchorPreference(
                            key: VisibleItemsPreference.self,
                            value: .bounds,
                            transform: { anchor in
                                [Payload(item: num, bounds: anchor)]
                        })
                        
                    
                }
            }
        }
        .onChange(of: visibles, { _, newValue in
            print( newValue)
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
                        DispatchQueue.main.async {
                            visibles = visibleItems
                        }
                    }
            }
        }
    }
}

extension [Text] {
    func joined(separator: Text) -> Text {
        guard let f = first else { return Text("") }
        return dropFirst().reduce(f, { $0 + separator + $1 })
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
