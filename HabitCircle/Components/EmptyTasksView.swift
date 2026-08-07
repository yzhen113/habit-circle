import SwiftUI

struct EmptyTasksView: View {
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(AppColors.greenTint)
                    .frame(width: 96, height: 96)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 42, weight: .regular))
                    .foregroundStyle(AppColors.green)
            }

            VStack(spacing: 6) {
                Text("All clear")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColors.black)

                Text("No tasks scheduled for this day.\nEnjoy the breather or add a new habit.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(AppColors.darkGray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, AppLayout.horizontalPadding)
        .contentShape(Rectangle())
    }
}

#Preview {
    EmptyTasksView()
}
