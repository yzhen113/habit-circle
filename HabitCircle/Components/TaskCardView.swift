import SwiftUI

struct TaskCardView: View {
    let task: TaskItem

    private var backgroundColor: Color {
        task.isCompleted ? AppColors.lightGray : task.tintColor
    }

    private var titleColor: Color {
        task.isCompleted ? AppColors.darkGray : AppColors.black
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            taskRow

            if task.hasPhotoVerification {
                PhotoVerificationPill()
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 16)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: AppLayout.taskCardCornerRadius, style: .continuous))
    }

    private var taskRow: some View {
        HStack(alignment: .center, spacing: 8) {
            TaskIconView(
                icon: task.icon,
                accentColor: task.accentColor,
                desaturated: task.isCompleted
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(AppTypography.taskTitle())
                    .foregroundStyle(titleColor)
                    .strikethrough(task.isCompleted, color: AppColors.darkGray)

                metadataRow
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var metadataRow: some View {
        HStack(spacing: 4) {
            Image(systemName: "alarm")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.darkGray)

            Text(task.reminderText)
                .font(AppTypography.metadata())
                .foregroundStyle(AppColors.darkGray)

            Text("•")
                .font(AppTypography.metadata())
                .foregroundStyle(AppColors.darkGray)

            Image(systemName: task.participantCount > 1 ? "person.2.fill" : "person.fill")
                .font(.system(size: 10))
                .foregroundStyle(AppColors.darkGray)

            Text("\(task.participantCount)")
                .font(AppTypography.metadata())
                .foregroundStyle(AppColors.darkGray)
        }
    }
}
