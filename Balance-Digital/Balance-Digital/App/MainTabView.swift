import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        ZStack {
            // Fondo general de la app
            Color(hex: "FBFBFD").ignoresSafeArea()
            
            // Switch de Vistas Maestras
            Group {
                switch selectedTab {
                case 0:
                    DashboardView()
                case 1:
                    MeditationView(onBack: { selectedTab = 0 })
                case 2:
                    LoginView(onLoginSuccess: { selectedTab = 0 })
                case 3:
                    ApproachView()
                case 4:
                    ProfileView()
                default:
                    DashboardView()
                }
            }
            .padding(.bottom, 80) // Evitar colisión con el menú global premium
            
            // Barra de Navegación Flotante Global
            VStack {
                Spacer()
                CustomTabBarView(selectedTab: $selectedTab) {
                    selectedTab = 2 
                }
            }
            .ignoresSafeArea(.keyboard)
            .zIndex(100)
        }
    }
}

// Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(ProfileViewModel())
    }
}
