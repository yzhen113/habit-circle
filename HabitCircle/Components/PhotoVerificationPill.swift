import SwiftUI

struct PhotoVerificationPill: View {
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "camera")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(AppColors.black)

            Text("Photo Verification")
                .font(AppTypography.photoVerification())
                .foregroundStyle(AppColors.black)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(AppColors.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
