import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .blue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : color)
                .background(
                    Capsule()
                        .fill(isSelected ? color : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(color, lineWidth: isSelected ? 0 : 1.5)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        FilterChip(title: "Tümü", isSelected: true) {
            print("Selected")
        }
        
        FilterChip(title: "Düğün", isSelected: false, color: .orange) {
            print("Wedding")
        }
        
        FilterChip(title: "Other", isSelected: false) {
            print("Other")
        }
    }
    .padding()
}
