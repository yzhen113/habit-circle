import SwiftUI

enum CreateFormMetrics {
    static let fieldCornerRadius: CGFloat = 26
    static let fieldHeight: CGFloat = 60
    static let textAreaHeight: CGFloat = 110
    static let categoryCornerRadius: CGFloat = 21.55
    static let footerButtonHeight: CGFloat = 56
}

/// "Group Name | Required" — pipe-separated label above each field.
struct CreateFieldLabel: View {
    let title: String
    var requirement: String?

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.black)

            if let requirement {
                Text("| \(requirement)")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(AppColors.darkGray)
            }
        }
    }
}

struct CreatePillTextField: View {
    let placeholder: String
    @Binding var text: String
    var characterLimit: Int = 40

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 16))
            .tint(AppColors.green)
            .padding(.horizontal, 20)
            .frame(height: CreateFormMetrics.fieldHeight)
            .background(
                AppColors.lightGray,
                in: RoundedRectangle(cornerRadius: CreateFormMetrics.fieldCornerRadius, style: .continuous)
            )
            .onChange(of: text) { _, newValue in
                if newValue.count > characterLimit {
                    text = String(newValue.prefix(characterLimit))
                }
            }
    }
}

struct CreatePillTextEditor: View {
    let placeholder: String
    @Binding var text: String
    var characterLimit: Int = 240

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.darkGray)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $text)
                .font(.system(size: 16))
                .tint(AppColors.green)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .frame(height: CreateFormMetrics.textAreaHeight)
        .background(
            AppColors.lightGray,
            in: RoundedRectangle(cornerRadius: CreateFormMetrics.fieldCornerRadius, style: .continuous)
        )
        .onChange(of: text) { _, newValue in
            if newValue.count > characterLimit {
                text = String(newValue.prefix(characterLimit))
            }
        }
    }
}

/// Selectable capsule used for durations and repeat options.
struct CreateSelectionChip: View {
    let title: String
    let isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(isSelected ? AppColors.white : AppColors.darkGray)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.green : AppColors.lightGray, in: Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.18), value: isSelected)
    }
}

/// Read-only capsule that opens a picker sheet (reminder time, repeats).
struct CreateValueChip: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17))
                .foregroundStyle(AppColors.darkGray)
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
                .background(AppColors.lightGray, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct CreateCategoryCard: View {
    let category: TaskCategory
    let isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 14) {
                Spacer(minLength: 0)

                Image(category.circleAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 58, height: 58)
                    .modifier(CategoryIconTint(isSelected: isSelected))

                Text(category.createTitle)
                    .font(.system(size: 16))
                    .foregroundStyle(isSelected ? AppColors.white : AppColors.darkGray)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(
                isSelected ? AppColors.green : AppColors.lightGray,
                in: RoundedRectangle(cornerRadius: CreateFormMetrics.categoryCornerRadius, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.2), value: isSelected)
    }
}

/// Knocks the category artwork out to solid white on the selected (green) card.
private struct CategoryIconTint: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        if isSelected {
            content
                .colorMultiply(.black)
                .colorInvert()
        } else {
            content
        }
    }
}

struct CreateMemberAvatar: View {
    let member: CircleMember
    let index: Int
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(member.initial)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.white)
                    .frame(width: 48, height: 48)
                    .background(AppColors.avatarColor(at: index), in: Circle())

                Text(member.name)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.darkGray)
                    .lineLimit(1)
            }
            .opacity(member.isInvited ? 1 : 0.38)
        }
        .buttonStyle(.plain)
    }
}

struct CreateAddMemberButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color(hex: 0x999999))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Circle().strokeBorder(Color(hex: 0xAEAEB2), lineWidth: 1)
                    }

                Text("Add")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.darkGray)
            }
        }
        .buttonStyle(.plain)
    }
}

/// Full-width black pill — the primary action on every create step.
struct CreatePrimaryButton: View {
    let title: String
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AppColors.white)
                .frame(maxWidth: .infinity)
                .frame(height: CreateFormMetrics.footerButtonHeight)
                .background(AppColors.black, in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.35 : 1)
        .animation(.easeOut(duration: 0.18), value: isDisabled)
    }
}

struct CreateSecondaryButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AppColors.black)
                .frame(maxWidth: .infinity)
                .frame(height: CreateFormMetrics.footerButtonHeight)
                .background(AppColors.lightGray, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
