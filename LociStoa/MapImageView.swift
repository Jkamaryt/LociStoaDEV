import SwiftUI

struct MapImageView: View {
    var floorNum: String
    var body: some View {
        Image(floorNum).resizable()
    }
}
