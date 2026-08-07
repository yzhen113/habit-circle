import SwiftUI

/// Shared Cancel / Title / Done bar used by every create-flow picker sheet.
private struct SheetHeader: View {
    let title: String
    var onCancel: () -> Void
    var onDone: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.black)

            HStack {
                Button("Cancel", action: onCancel)
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.darkGray)
                Spacer()
                Button("Done", action: onDone)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.green)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 8)
    }
}

// MARK: - Reminder time

struct ReminderTimeSheet: View {
    @Binding var time: Date
    var onDismiss: () -> Void

    @State private var draftTime: Date

    init(time: Binding<Date>, onDismiss: @escaping () -> Void) {
        _time = time
        _draftTime = State(initialValue: time.wrappedValue)
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Reminder Time", onCancel: onDismiss) {
                time = draftTime
                onDismiss()
            }

            DatePicker("", selection: $draftTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }
}

// MARK: - Repeats

struct RepeatsSheet: View {
    @Binding var rule: RepeatRule
    @Binding var interval: Int
    @Binding var unit: RepeatUnit
    var onDismiss: () -> Void

    @State private var draftRule: RepeatRule
    @State private var draftInterval: Int
    @State private var draftUnit: RepeatUnit

    init(
        rule: Binding<RepeatRule>,
        interval: Binding<Int>,
        unit: Binding<RepeatUnit>,
        onDismiss: @escaping () -> Void
    ) {
        _rule = rule
        _interval = interval
        _unit = unit
        _draftRule = State(initialValue: rule.wrappedValue)
        _draftInterval = State(initialValue: interval.wrappedValue)
        _draftUnit = State(initialValue: unit.wrappedValue)
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Repeats", onCancel: onDismiss) {
                rule = draftRule
                interval = draftInterval
                unit = draftUnit
                onDismiss()
            }

            VStack(spacing: 0) {
                ForEach(RepeatRule.allCases) { option in
                    Button {
                        withAnimation(.easeOut(duration: 0.18)) { draftRule = option }
                    } label: {
                        HStack {
                            Text(option.title)
                                .font(.system(size: 17))
                                .foregroundStyle(AppColors.black)
                            Spacer()
                            if draftRule == option {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(AppColors.green)
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 52)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if option != RepeatRule.allCases.last {
                        Divider().padding(.leading, 20)
                    }
                }

                if draftRule == .custom {
                    Divider().padding(.leading, 20)

                    HStack(spacing: 12) {
                        Text("Every")
                            .font(.system(size: 17))
                            .foregroundStyle(AppColors.black)

                        Stepper(value: $draftInterval, in: 1...30) {
                            Text("\(draftInterval)")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(AppColors.black)
                                .frame(minWidth: 28)
                        }
                        .fixedSize()

                        Picker("", selection: $draftUnit) {
                            ForEach(RepeatUnit.allCases) { unit in
                                Text(unit.title).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 60)
                    .transition(.opacity)
                }
            }

            Spacer(minLength: 0)
        }
        .presentationDetents([.height(draftRule == .custom ? 400 : 340)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }
}

// MARK: - Visibility

struct VisibilitySheet: View {
    @Binding var visibility: CircleVisibility
    var onDismiss: () -> Void

    @State private var draftVisibility: CircleVisibility

    init(visibility: Binding<CircleVisibility>, onDismiss: @escaping () -> Void) {
        _visibility = visibility
        _draftVisibility = State(initialValue: visibility.wrappedValue)
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Visibility", onCancel: onDismiss) {
                visibility = draftVisibility
                onDismiss()
            }

            ForEach(CircleVisibility.allCases) { option in
                Button {
                    withAnimation(.easeOut(duration: 0.18)) { draftVisibility = option }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: option.systemImage)
                            .font(.system(size: 17))
                            .foregroundStyle(AppColors.black)
                            .frame(width: 22)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(AppColors.black)
                            Text(option.hint)
                                .font(.system(size: 13))
                                .foregroundStyle(AppColors.darkGray)
                        }

                        Spacer(minLength: 8)

                        if draftVisibility == option {
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppColors.green)
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 68)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if option != CircleVisibility.allCases.last {
                    Divider().padding(.leading, 20)
                }
            }

            Spacer(minLength: 0)
        }
        .presentationDetents([.height(260)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }
}
