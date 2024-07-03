import SwiftUI

struct AppToastView: View {
    @Binding var isShow: Bool
    let info: String
    @State private var isShowAnimation: Bool = true
    @State private var duration : Double
    
    init(isShow:Binding<Bool>, info: String = "", duration:Double = 1.0) {
        self._isShow = isShow
        self.info = info
        self.duration = duration
    }
    
    var body: some View {
        ZStack {
            Text(info)
                .font(Font.body)
                .foregroundColor(.white)
                .frame(minWidth: 80, alignment: Alignment.center)
                .zIndex(1.0)
                .padding([.top, .bottom], 12)
                .padding([.leading, .trailing], 24)
                .background(
                    RoundedRectangle(cornerRadius: 12).foregroundColor(.black).opacity(0.8)
                )
        }
        .opacity(isShowAnimation ? 1 : 0)
        .animation(.easeIn(duration: 0.8), value: isShowAnimation ? 1 : 0)
        .edgesIgnoringSafeArea(.all)
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                isShowAnimation = false
            }
        }
        .onChange(of: isShowAnimation) { e in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isShow = false
            }
        }
    }
}

extension View {
    func toast(isShow:Binding<Bool>, info:String = "",  duration:Double = 1.0) -> some View {
        ZStack {
            self
            if isShow.wrappedValue {
                AppToastView(isShow:isShow, info:info, duration: duration)
            }
        }
    }
}
