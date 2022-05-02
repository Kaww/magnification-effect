import SwiftUI

struct ContentView: View {
    var body: some View {
        DockView()
            .padding()
    }
}

struct DockView: View {
    let screen = UIScreen.main.bounds.size

    private let apps = [ "Message", "Mail", "Notes", "Reminders", "Camera", "Photos", "Clock", "Weather" ]
    private let spacing: CGFloat = 8
    private let dockHeight: CGFloat = 60
    private var dockPadding: CGFloat { dockHeight / 4 }
    private var maxStillAppSize: CGFloat {
        dockHeight / 2
    }

    @State private var xPosition: CGFloat? = nil

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .foregroundColor(.gray.opacity(0.2))
                        .frame(height: dockHeight)

                    HStack(alignment: .bottom, spacing: spacing) {
                        ForEach(0..<Int(apps.count), id: \.self) { index in
                            let appSize = appSize(for: index, in: geometry.size)

                            Image(apps[index])
                                .resizable()
                                .frame(width: appSize, height: appSize)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding([.bottom, .horizontal], dockPadding)
                }
                .animation(
                    .spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0),
                    value: xPosition
                )
                .onTouch(limitToBounds: false) { pos, touchType in
                    if touchType == .ended {
                        xPosition = nil
                    } else {
                        xPosition = pos.x
                    }
                }
            }
        }
    }

    private func appSize(for index: Int, in docSize: CGSize) -> CGFloat {
        let intrinsecWidth = docSize.width - (CGFloat(apps.count) - 1) * spacing - 2 * dockPadding
        let calculatedSize = intrinsecWidth / CGFloat(apps.count)
        let idealAppSize = calculatedSize > maxStillAppSize ? maxStillAppSize : calculatedSize

        if let xPosition = xPosition {
            let appCenter = dockPadding + (CGFloat(index) + 1) * calculatedSize + CGFloat(index) * spacing - 0.5 * calculatedSize

            let distance = abs(appCenter - xPosition)

            let ratio = map(distance, fromRange: (0, docSize.width), toRange: (0.5, 2.5))

            return idealAppSize * 1 / (ratio ?? 1)
        }

        return idealAppSize
    }

    func map(_ number: CGFloat, fromRange: (CGFloat, CGFloat), toRange: (CGFloat, CGFloat)) -> CGFloat? {
        guard number >= fromRange.0 && number <= fromRange.1,
            toRange.0 <= toRange.1 else { return nil }
        return toRange.0 + (number-fromRange.0)*(toRange.1-toRange.0)/(fromRange.1-fromRange.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
