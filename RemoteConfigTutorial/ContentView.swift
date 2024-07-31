import SwiftUI

struct ContentView: View {
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    
    var body: some View {
        VStack {
            Text("Welcome to the app!")
        }
        .alert(isPresented: $remoteConfigManager.forceUpdateRequired) {
                    Alert(
                        title: Text("更新が必要です"),
                        message: Text("アプリの新しいバージョンが利用可能です。アプリを引き続き使用するには更新してください。"),
                        dismissButton: .default(Text("OK")) {
                            // テスト用なので、ここでは何もアクションを起こしません
                            print("更新アラートが解除されました")
                        }
                    )
                }
    }
}
