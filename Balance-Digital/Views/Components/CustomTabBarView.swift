
import SwiftUI
import UIKit

struct TabCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let mid = rect.width / 2
        let curveWidth: CGFloat = 100
        let dip: CGFloat = 45
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: mid - curveWidth / 2, y: 0))
        
        path.addCurve(
            to: CGPoint(x: mid, y: dip),
            control1: CGPoint(x: mid - curveWidth / 3.5, y: 0),
            control2: CGPoint(x: mid - curveWidth / 3.5, y: dip)
        )
        
        path.addCurve(
            to: CGPoint(x: mid + curveWidth / 2, y: 0),
            control1: CGPoint(x: mid + curveWidth / 3.5, y: dip),
            control2: CGPoint(x: mid + curveWidth / 3.5, y: 0)
        )
        
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height + 150))
        path.addLine(to: CGPoint(x: 0, y: rect.height + 150))
        return path
    }
}

struct CustomTabBarView: View {
    @Binding var selectedTab: Int
    var onAction: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            // Fondo oscuro con recorte
            TabCurveShape()
                .fill(Color(hex: "1A1A1A"))
                .shadow(color: Color.black.opacity(0.18), radius: 15, x: 0, y: -6)
                .ignoresSafeArea(edges: .bottom)

            HStack(spacing: 0) {
                tabButtonItem(title: "Dashboard", icon: "chart.bar", selectedIcon: "chart.bar.fill", index: 0)
                tabButtonItem(title: "Meditación", icon: "leaf", selectedIcon: "leaf.fill", index: 1)
                
                Spacer().frame(width: 80) // Espacio para el botón central (3er botón)
                
                tabButtonItem(title: "Enfoque", icon: "target", selectedIcon: "target", index: 3)
                tabButtonItem(title: "Perfil", icon: "person", selectedIcon: "person.fill", index: 4)
            }
            .padding(.horizontal, 16)
            .frame(height: 70)

            // Logo Central Estático
            ZStack {
                Circle()
                    .fill(Color(hex: "FBFBFD"))
                    .frame(width: 76, height: 76)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.black, Color(hex: "2D2D2D")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 62, height: 62)
                    
                Image(systemName: "leaf.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            .offset(y: -30)
        }
        .frame(height: 70)
    }

    private func tabButtonItem(title: String, icon: String, selectedIcon: String, index: Int) -> some View {
        let isSelected = selectedTab == index

        return Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = index
            }
            HapticManager.impact(style: .soft)
        }) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? selectedIcon : icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : Color.white.opacity(0.7))
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : Color.white.opacity(0.7))
                
                Circle()
                    .fill(Color(hex: "5CE1E6"))
                    .frame(width: 4, height: 4)
                    .opacity(isSelected ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .contentShape(Rectangle())
        }
    }
}

struct CustomTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(hex: "FBFBFD").ignoresSafeArea()
            VStack {
                Spacer()
                CustomTabBarView(selectedTab: .constant(0), onAction: {})
            }
        }
    }
}
