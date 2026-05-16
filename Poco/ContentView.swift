//
//  ContentView.swift
//  Poco
//
//  Created by 윤여명 on 5/12/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isChatPresented = false
    @State private var isCalendarPresented = false
    @State private var focusedTask: FocusTask?
    @State private var selectedTab: PocoTab = .home
    @State private var showDummyData = true
    @State private var selectedTheme: ThemeMode = .system
    @State private var expandedTaskID: UUID?
    @State private var swipedTaskID: UUID?
    @State private var showMissingInfoCard = false
    @State private var showImageParsingMock = true
    @State private var showSharedImageMock = true
    @State private var showTaskEditChatMock = true
    @State private var showPriorityChatMock = true
    @State private var showGeneratedImageTask = true

    private var tasks: [FocusTask] {
        var visibleTasks = showDummyData ? sampleTasks : []
        if showGeneratedImageTask {
            visibleTasks.insert(imageGeneratedTask, at: 0)
        }
        return visibleTasks.sorted { $0.priorityLevel > $1.priorityLevel }
    }

    private let imageGeneratedTask = FocusTask(
        title: "운영체제 과제 제출",
        deadline: "이번 주 금요일",
        progress: 0.46,
        priority: "이미지에서 생성됨",
        nextStep: "필요 파일 이름 적기",
        tint: .refocusViolet,
        priorityLevel: 2,
        smallActions: ["LMS 공지 다시 열기", "제출 조건 확인하기", "필요 파일 이름 적기", "첫 문장만 작성하기"],
        currentStepIndex: 2
    )

    private let sampleTasks: [FocusTask] = [
        FocusTask(
            title: "닷넷 과제 정리",
            deadline: "오늘 저녁",
            progress: 0.62,
            priority: "먼저 시작",
            nextStep: "풀이 구조만 적기",
            tint: .refocusViolet,
            priorityLevel: 4,
            smallActions: ["요구사항 파일 열기", "모르는 부분 표시하기", "풀이 구조만 적기", "제출 전 확인하기"],
            currentStepIndex: 2
        ),
        FocusTask(
            title: "자료구조 복습",
            deadline: "내일 오전",
            progress: 0.50,
            priority: "짧게 확인",
            nextStep: "예제 하나만 풀기",
            tint: .refocusLilac,
            priorityLevel: 2,
            smallActions: ["스택 개념 10분 읽기", "예제 하나만 풀기"],
            currentStepIndex: 1
        ),
        FocusTask(
            title: "팀플 회의 준비",
            deadline: "금요일",
            progress: 0.58,
            priority: "이어 하기",
            nextStep: "질문 하나 적기",
            tint: .refocusMint,
            priorityLevel: 1,
            smallActions: ["지난 회의 메모 보기", "내 담당 부분 표시하기", "질문 하나 적기"],
            currentStepIndex: 2
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                PocoBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        headerDivider
                        mainContent
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                    .padding(.bottom, 210)
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 12)
                        .onChanged { value in
                            if abs(value.translation.height) > abs(value.translation.width) {
                                swipedTaskID = nil
                            }
                        }
                )

                bottomActionArea
            }
            .navigationDestination(item: $focusedTask) { task in
                FocusSessionView(task: task)
            }
            .sheet(isPresented: $isChatPresented) {
                AIChatView(
                    showImageParsingMock: showImageParsingMock,
                    showSharedImageMock: showSharedImageMock,
                    showTaskEditChatMock: showTaskEditChatMock,
                    showPriorityChatMock: showPriorityChatMock,
                    showGeneratedImageTask: showGeneratedImageTask
                )
                    .presentationDetents([.large], selection: .constant(.large))
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isCalendarPresented) {
                CalendarHistoryView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
        .preferredColorScheme(selectedTheme.colorScheme)
    }

    private var headerTitle: String {
        switch selectedTab {
        case .home: "한 가지 일에 Focus"
        case .tasks: "할 일 목록"
        case .calendar: "캘린더"
        case .settings: "설정"
        }
    }

    private var headerDivider: some View {
        Rectangle()
            .fill(Color.refocusLine.opacity(0.8))
            .frame(height: 1)
            .padding(.horizontal, 10)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("5월 12일 화요일")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.refocusViolet)
                Text(headerTitle)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.refocusInk)
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        switch selectedTab {
        case .home:
            if showMissingInfoCard {
                MissingInfoCard()
            }
            currentWorkSummary
        case .tasks:
            taskList
        case .calendar:
            CalendarTabContent()
        case .settings:
            SettingsTabContent(
                showDummyData: $showDummyData,
                selectedTheme: $selectedTheme,
                showMissingInfoCard: $showMissingInfoCard,
                showImageParsingMock: $showImageParsingMock,
                showSharedImageMock: $showSharedImageMock,
                showTaskEditChatMock: $showTaskEditChatMock,
                showPriorityChatMock: $showPriorityChatMock,
                showGeneratedImageTask: $showGeneratedImageTask
            )
        }
    }

    private var currentWorkSummary: some View {
        Group {
            if let nextTask = tasks.first {
                HomeResumeCard(task: nextTask) {
                    focusedTask = nextTask
                }
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    Text("아직 집중할 업무가 없어요")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.refocusInk)
                    Text("아래 과녁 버튼을 눌러 키워드만 적어보세요.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.refocusMuted)
                }
                .frame(maxWidth: .infinity, minHeight: 360, alignment: .topLeading)
                .padding(24)
                .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .refocusShadow, radius: 28, y: 14)
            }
        }
    }

    private var taskList: some View {
        VStack(alignment: .leading, spacing: 14) {
            if tasks.isEmpty {
                EmptyTaskView()
            } else {
                ForEach(tasks) { task in
                    SwipeableTaskRow(
                        task: task,
                        isExpanded: expandedTaskID == task.id,
                        swipedTaskID: $swipedTaskID,
                        onToggle: {
                            swipedTaskID = nil
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                                expandedTaskID = expandedTaskID == task.id ? nil : task.id
                            }
                        },
                        onFocus: {
                            swipedTaskID = nil
                            focusedTask = task
                        }
                    )
                }
            }
        }
    }

    private var bottomActionArea: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color.white)
                .frame(height: 160)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.refocusLine.opacity(0.75))
                        .frame(height: 1)
                }
                .offset(y: 88)
                .allowsHitTesting(false)

            HStack(alignment: .center, spacing: 0) {
                NavigationBarItem(tab: .home, selectedTab: $selectedTab, swipedTaskID: $swipedTaskID)
                NavigationBarItem(tab: .tasks, selectedTab: $selectedTab, swipedTaskID: $swipedTaskID)

                addTaskButton
                    .frame(maxWidth: .infinity)
                    .frame(height: 108)

                NavigationBarItem(tab: .calendar, selectedTab: $selectedTab, swipedTaskID: $swipedTaskID)
                NavigationBarItem(tab: .settings, selectedTab: $selectedTab, swipedTaskID: $swipedTaskID)
            }
            .frame(height: 108)
            .padding(.horizontal, 12)
            .padding(.bottom, 0)
            .offset(y: 18)
            .contentShape(Rectangle())
        }
        .frame(height: 168)
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(edges: .bottom)
    }

    private var addTaskButton: some View {
        Button {
            swipedTaskID = nil
            isChatPresented = true
        } label: {
            RippleTargetButton()
        }
        .accessibilityLabel("AI와 할 일 추가")
        .padding(.bottom, 2)
    }
}

private struct MissingInfoCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.bubble.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.refocusViolet)
                .frame(width: 38, height: 38)
                .background(Color.refocusViolet.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text("업무 생성에 필요한 정보가 있어요")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.refocusInk)
                Text("이미지에서 과제 정보를 읽었지만 마감기한과 중요도 확인이 필요해요. AI 채팅창을 확인해주세요.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.refocusMuted)
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .refocusShadow, radius: 18, y: 9)
    }
}

private enum PocoTab: CaseIterable {
    case home
    case tasks
    case calendar
    case settings

    var title: String {
        switch self {
        case .home: "홈"
        case .tasks: "할일"
        case .calendar: "캘린더"
        case .settings: "설정"
        }
    }

    var iconName: String {
        switch self {
        case .home: "house"
        case .tasks: "checklist"
        case .calendar: "calendar"
        case .settings: "gearshape"
        }
    }
}

private enum ThemeMode: String, CaseIterable, Identifiable {
    case light
    case dark
    case system

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: "라이트모드"
        case .dark: "다크모드"
        case .system: "시스템따라"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        case .system: nil
        }
    }
}

private struct NavigationBarItem: View {
    let tab: PocoTab
    @Binding var selectedTab: PocoTab
    @Binding var swipedTaskID: UUID?

    private var isSelected: Bool {
        selectedTab == tab
    }

    var body: some View {
        Button {
            swipedTaskID = nil
            selectedTab = tab
        } label: {
            VStack(spacing: 5) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(height: 22)
                Text(tab.title)
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(isSelected ? Color.refocusViolet : Color.refocusMuted)
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .padding(.top, 8)
            .contentShape(Rectangle())
            .background(Color.white.opacity(0.001))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
    }
}

private struct RippleTargetButton: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.96))
                .frame(width: 88, height: 88)
                .overlay {
                    Circle()
                        .stroke(Color.refocusViolet.opacity(0.12), lineWidth: 1)
                }
                .shadow(color: Color.refocusViolet.opacity(0.28), radius: 28, y: 14)

            Circle()
                .stroke(Color.refocusViolet.opacity(0.28), lineWidth: 12)
                .frame(width: 68, height: 68)

            Circle()
                .stroke(Color.refocusViolet, lineWidth: 2.4)
                .frame(width: 44, height: 44)

            Circle()
                .fill(Color.refocusViolet)
                .frame(width: 17, height: 17)
        }
        .frame(width: 124, height: 124)
        .contentShape(Circle())
    }
}

private struct HomeResumeCard: View {
    let task: FocusTask
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                Label("진행중인 업무", systemImage: "book.closed.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(task.tint)
                Spacer()
                Text(task.deadline)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(task.priorityColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(task.priorityColor.opacity(0.12), in: Capsule())
            }

            Text(task.title)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Color.refocusInk)
                .lineLimit(2)
                .minimumScaleFactor(0.74)

            MirroredHomeProgressBar(
                completedSteps: task.currentStepIndex + 1,
                totalSteps: max(task.smallActions.count, 1),
                tint: task.tint
            )
            .frame(height: 58)

            VStack(alignment: .leading, spacing: 10) {
                Text("중단 지점")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.refocusMuted)
                Text("풀이 구조를 적으려다 멈췄어요")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Color.refocusInk)
                    .lineLimit(2)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.refocusInk.opacity(0.045), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.refocusLine.opacity(0.7), lineWidth: 1)
            )

            Image(systemName: "arrow.down")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(task.tint.opacity(0.72))
                .frame(maxWidth: .infinity)
                .padding(.vertical, -4)

            VStack(alignment: .leading, spacing: 10) {
                Text("돌아오면 이것부터")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(task.tint)
                Text("표시해둔 부분부터 한 줄만 채우기")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.refocusInk)
                    .lineLimit(2)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(task.tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 26, style: .continuous))

            Button(action: onContinue) {
                Label("이어 하기", systemImage: "play.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(task.tint, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 450, alignment: .top)
        .padding(24)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .refocusShadow, radius: 30, y: 16)
    }
}

private struct MirroredHomeProgressBar: View {
    let completedSteps: Int
    let totalSteps: Int
    let tint: Color

    private var clampedCompletedSteps: Int {
        min(max(completedSteps, 0), totalSteps)
    }

    private var fillRatio: CGFloat {
        guard totalSteps > 0 else { return 0 }
        return CGFloat(clampedCompletedSteps) / CGFloat(totalSteps)
    }

    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.refocusLilac.opacity(0.55),
                Color.refocusViolet.opacity(0.82),
                Color.refocusViolet
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let trackHeight: CGFloat = 34
            let circleSize: CGFloat = 46
            let horizontalInset = circleSize / 2
            let availableWidth = max(width - circleSize, 1)
            let fillWidth = availableWidth * fillRatio + circleSize / 2

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.refocusLine.opacity(0.58))
                    .frame(height: trackHeight)
                    .overlay {
                        Capsule()
                            .stroke(Color.refocusLine.opacity(0.62), lineWidth: 1)
                    }

                Capsule()
                    .fill(progressGradient)
                    .frame(width: fillWidth, height: trackHeight)
                    .shadow(color: Color.refocusViolet.opacity(0.14), radius: 10, y: 4)

                ForEach(0..<totalSteps, id: \.self) { index in
                    let isCompleted = index < max(clampedCompletedSteps - 1, 0)
                    let isCurrent = index == clampedCompletedSteps - 1
                    progressNode(
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        isFinalPending: !isCompleted && !isCurrent && index == totalSteps - 1,
                        color: nodeColor(for: index),
                        size: circleSize
                    )
                    .position(
                        x: nodeXPosition(index: index, width: width, horizontalInset: horizontalInset),
                        y: height / 2
                    )
                }
            }
        }
    }

    private func nodeXPosition(index: Int, width: CGFloat, horizontalInset: CGFloat) -> CGFloat {
        guard totalSteps > 1 else { return width / 2 }
        let ratio = CGFloat(index) / CGFloat(totalSteps - 1)
        return horizontalInset + (width - horizontalInset * 2) * ratio
    }

    private func nodeColor(for index: Int) -> Color {
        guard totalSteps > 1 else { return tint }
        let ratio = CGFloat(index) / CGFloat(totalSteps - 1)
        let opacity = 0.52 + ratio * 0.48
        return Color.refocusViolet.opacity(opacity)
    }

    private func progressNode(isCompleted: Bool, isCurrent: Bool, isFinalPending: Bool, color: Color, size: CGFloat) -> some View {
        Circle()
            .fill(isCompleted || isCurrent ? Color.white.opacity(0.92) : Color.refocusLine.opacity(0.72))
            .frame(width: size, height: size)
            .overlay {
                Circle()
                    .stroke(isCompleted || isCurrent ? color : Color.refocusLine.opacity(0.2), lineWidth: isCompleted || isCurrent ? 3.5 : 0)
            }
            .overlay {
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(color)
                } else if isCurrent {
                    Circle()
                        .stroke(color, lineWidth: 2.2)
                        .frame(width: 15, height: 15)
                } else if isFinalPending {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.refocusMuted.opacity(0.62))
                }
            }
            .shadow(color: isCompleted || isCurrent ? color.opacity(0.20) : .clear, radius: 7, y: 3)
            .opacity(isCompleted || isCurrent || isFinalPending ? 1 : 0.55)
    }
}

private struct SegmentedStepProgress: View {
    let currentStep: Int
    let totalSteps: Int
    let tint: Color

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? tint : Color.refocusLine)
                    .frame(height: 8)
            }
        }
    }
}

private struct FocusStepRow: View {
    let index: Int
    let title: String
    let status: String
    let isActive: Bool
    let isDone: Bool
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isActive ? tint : isDone ? tint.opacity(0.22) : Color.white.opacity(0.88))
                        .frame(width: 30, height: 30)
                    if isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(tint)
                    } else {
                        Text("\(index)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(isActive ? .white : Color.refocusMuted)
                    }
                }

                if index < 4 {
                    Rectangle()
                        .fill(isDone ? tint.opacity(0.28) : Color.refocusLine)
                        .frame(width: 2, height: 14)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: isActive ? 16 : 14, weight: isActive ? .bold : .semibold))
                    .foregroundStyle(isActive ? Color.refocusInk : Color.refocusMuted)
                    .lineLimit(2)
                Text(status)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isActive ? tint : Color.refocusMuted.opacity(0.75))
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
    }
}

private struct EmptyTaskView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "tray")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.refocusViolet)
            Text("표시할 할 일이 없어요")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.refocusInk)
            Text("설정에서 더미데이터를 다시 켜거나, AI 버튼으로 새 할 일을 추가해보세요.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.refocusMuted)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .refocusShadow, radius: 18, y: 9)
    }
}

private struct CalendarTabContent: View {
    private let days = Array(1...31)
    private let activeDays: Set<Int> = [3, 6, 8, 12]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 10) {
                ForEach(days, id: \.self) { day in
                    VStack(spacing: 5) {
                        Text("\(day)")
                            .font(.system(size: 14, weight: day == 12 ? .bold : .medium))
                            .foregroundStyle(day == 12 ? .white : Color.refocusInk)
                        Circle()
                            .fill(activeDays.contains(day) ? Color.refocusViolet : Color.clear)
                            .frame(width: 5, height: 5)
                    }
                    .frame(height: 46)
                    .frame(maxWidth: .infinity)
                    .background(day == 12 ? Color.refocusViolet : Color.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("5월 12일")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.refocusInk)
                Text("오늘은 닷넷 과제와 자료구조 복습을 바로 시작할 업무로 정리했어요.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.refocusMuted)
                    .lineSpacing(3)
            }
            .padding(18)
            .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .refocusShadow, radius: 18, y: 9)
        }
    }
}

private struct SettingsTabContent: View {
    @Binding var showDummyData: Bool
    @Binding var selectedTheme: ThemeMode
    @Binding var showMissingInfoCard: Bool
    @Binding var showImageParsingMock: Bool
    @Binding var showSharedImageMock: Bool
    @Binding var showTaskEditChatMock: Bool
    @Binding var showPriorityChatMock: Bool
    @Binding var showGeneratedImageTask: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(spacing: 18) {
                SettingsToggleRow(
                    title: "기본 할 일 목록",
                    subtitle: "기존 샘플 업무 카드들을 표시해요.",
                    isOn: $showDummyData
                )

                Divider()
                    .background(Color.refocusLine)

                SettingsToggleRow(
                    title: "이미지로 생성된 업무",
                    subtitle: "OCR/AI 파싱 결과로 생성된 업무 카드를 보여줘요.",
                    isOn: $showGeneratedImageTask
                )

                Divider()
                    .background(Color.refocusLine)

                SettingsToggleRow(
                    title: "부족 정보 알림 카드",
                    subtitle: "홈 상단에 채팅 확인 안내 카드를 표시해요.",
                    isOn: $showMissingInfoCard
                )

                Divider()
                    .background(Color.refocusLine)

                SettingsToggleRow(
                    title: "AI 채팅 이미지 파싱 목업",
                    subtitle: "채팅창에 이미지 첨부, OCR, 역질문 흐름을 표시해요.",
                    isOn: $showImageParsingMock
                )

                Divider()
                    .background(Color.refocusLine)

                SettingsToggleRow(
                    title: "공유 이미지 유입 목업",
                    subtitle: "스크린샷 공유로 앱이 열린 상황을 채팅에 표시해요.",
                    isOn: $showSharedImageMock
                )

                Divider()
                    .background(Color.refocusLine)

                SettingsToggleRow(
                    title: "업무 내용 수정 대화",
                    subtitle: "진행 중인 업무의 일부 내용을 AI가 조정하는 대화를 표시해요.",
                    isOn: $showTaskEditChatMock
                )

                Divider()
                    .background(Color.refocusLine)

                SettingsToggleRow(
                    title: "우선순위 조정 대화",
                    subtitle: "두 업무 중 무엇을 먼저 할지 AI와 짧게 정하는 대화를 표시해요.",
                    isOn: $showPriorityChatMock
                )

                Divider()
                    .background(Color.refocusLine)

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("테마")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.refocusInk)
                        Text("앱 화면의 밝기 스타일을 선택해요.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.refocusMuted)
                    }

                    Picker("테마", selection: $selectedTheme) {
                        ForEach(ThemeMode.allCases) { mode in
                            Text(mode.title)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(.refocusViolet)
                }
            }
            .padding(18)
            .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .refocusShadow, radius: 18, y: 9)
        }
    }
}

private struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.refocusInk)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.refocusMuted)
                    .lineLimit(2)
            }
        }
        .tint(.refocusViolet)
    }
}

private struct SwipeableTaskRow: View {
    let task: FocusTask
    let isExpanded: Bool
    @Binding var swipedTaskID: UUID?
    let onToggle: () -> Void
    let onFocus: () -> Void

    @State private var offsetX: CGFloat = 0
    @State private var dragStartOffset: CGFloat = 0
    @State private var isDragging = false

    private let actionOffset: CGFloat = 100
    private let actionButtonWidth: CGFloat = 88
    private let activationThreshold: CGFloat = 70
    private let dragDeadZone: CGFloat = 22

    private var revealProgress: CGFloat {
        min(abs(offsetX) / actionOffset, 1)
    }

    var body: some View {
        ZStack {
            actionButtons
                .allowsHitTesting(abs(offsetX) > 70)

            TaskCard(task: task, isExpanded: isExpanded)
                .offset(x: offsetX)
                .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .onTapGesture {
                    if offsetX == 0 {
                        onToggle()
                    } else {
                        closeActions()
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            guard abs(value.translation.width) > abs(value.translation.height) * 1.45 else { return }

                            if !isDragging {
                                isDragging = true
                                dragStartOffset = offsetX
                            }

                            swipedTaskID = task.id
                            offsetX = adjustedOffset(for: value.translation.width)
                        }
                        .onEnded { value in
                            defer {
                                isDragging = false
                                dragStartOffset = 0
                            }

                            guard abs(value.translation.width) > abs(value.translation.height) * 1.45 else {
                                settleToNearestState()
                                return
                            }

                            settleAfterDrag(translation: value.translation.width)
                        }
                )
                .animation(.spring(response: 0.28, dampingFraction: 0.86), value: offsetX)
                .zIndex(0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onChange(of: swipedTaskID) { _, newValue in
            if newValue != task.id {
                closeActions()
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 0) {
            Button {
                swipedTaskID = nil
            } label: {
                actionLabel(title: "삭제", systemImage: "trash")
                    .frame(width: actionButtonWidth)
                    .frame(maxHeight: .infinity)
                    .background(deleteActionColor, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .opacity(offsetX > 0 ? buttonOpacity : 0)
            .scaleEffect(0.94 + revealProgress * 0.06)

            Spacer(minLength: 0)

            Button {
                onFocus()
                swipedTaskID = nil
            } label: {
                actionLabel(title: "집중", systemImage: "timer")
                    .frame(width: actionButtonWidth)
                    .frame(maxHeight: .infinity)
                    .background(focusActionColor, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .opacity(offsetX < 0 ? buttonOpacity : 0)
            .scaleEffect(0.94 + revealProgress * 0.06)
        }
        .padding(.vertical, 7)
        .background(Color.refocusLine.opacity(revealProgress * 0.18))
    }

    private var buttonOpacity: CGFloat {
        0.22 + revealProgress * 0.78
    }

    private var focusActionColor: Color {
        Color(red: 0.46, green: 0.39, blue: 0.72)
    }

    private var deleteActionColor: Color {
        Color(red: 0.70, green: 0.36, blue: 0.36)
    }

    private func actionLabel(title: String, systemImage: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .bold))
            Text(title)
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundStyle(.white.opacity(0.96))
    }

    private func adjustedOffset(for translation: CGFloat) -> CGFloat {
        if dragStartOffset > 0 {
            return min(max(dragStartOffset + translation, 0), actionOffset)
        }

        if dragStartOffset < 0 {
            return max(min(dragStartOffset + translation, 0), -actionOffset)
        }

        guard abs(translation) > dragDeadZone else { return 0 }
        let adjustedTranslation = translation - (translation > 0 ? dragDeadZone : -dragDeadZone)
        return min(max(adjustedTranslation, -actionOffset), actionOffset)
    }

    private func settleAfterDrag(translation: CGFloat) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            if dragStartOffset > 0 {
                offsetX = translation < -24 ? 0 : actionOffset
            } else if dragStartOffset < 0 {
                offsetX = translation > 24 ? 0 : -actionOffset
            } else if translation > activationThreshold {
                offsetX = actionOffset
            } else if translation < -activationThreshold {
                offsetX = -actionOffset
            } else {
                offsetX = 0
            }

            swipedTaskID = offsetX == 0 ? nil : task.id
        }
    }

    private func settleToNearestState() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            if offsetX > actionOffset * 0.55 {
                offsetX = actionOffset
            } else if offsetX < -actionOffset * 0.55 {
                offsetX = -actionOffset
            } else {
                offsetX = 0
            }

            swipedTaskID = offsetX == 0 ? nil : task.id
        }
    }

    private func closeActions() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            offsetX = 0
        }
    }
}

private struct TaskCard: View {
    let task: FocusTask
    let isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(task.priorityColor.opacity(0.18))
                    .frame(width: 42, height: 42)
                    .overlay {
                        Image(systemName: task.priorityIconName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(task.priorityColor)
                    }

                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 8) {
                        Text(task.priorityLabel)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(task.priorityColor, in: Capsule())

                        Text(task.deadline)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(task.priorityColor)
                    }

                    Text(task.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.refocusInk)
                        .lineLimit(2)

                    Text(task.nextStep)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.refocusMuted)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.refocusMuted.opacity(0.5))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(task.priority)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(task.priorityColor)
                    Spacer()
                    Text("\(Int(task.progress * 100))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.refocusMuted)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.refocusLine)
                        Capsule()
                            .fill(task.priorityColor)
                            .frame(width: max(12, proxy.size.width * task.progress))
                    }
                }
                .frame(height: 8)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text("수행 과정")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.refocusMuted)

                    ProcessTimelineView(task: task)
                }
                .padding(14)
                .background(task.priorityColor.opacity(0.07), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(18)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(task.priorityColor.opacity(task.priorityLevel >= 3 ? 0.22 : 0.08), lineWidth: task.priorityLevel >= 3 ? 1.5 : 1)
        )
        .shadow(color: task.priorityColor.opacity(task.priorityLevel >= 3 ? 0.16 : 0.08), radius: 20, y: 10)
    }
}

private struct ProcessTimelineView: View {
    let task: FocusTask

    private let rowHeight: CGFloat = 30
    private let markerColumnWidth: CGFloat = 22

    private var markerColor: Color {
        task.priorityColor.opacity(0.82)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if task.smallActions.count > 1 {
                Rectangle()
                    .fill(markerColor.opacity(0.48))
                    .frame(width: 1.5, height: CGFloat(task.smallActions.count - 1) * rowHeight)
                    .offset(x: markerColumnWidth / 2 - 0.75, y: rowHeight / 2)
            }

            VStack(spacing: 0) {
                ForEach(Array(task.smallActions.enumerated()), id: \.offset) { index, action in
                    HStack(alignment: .center, spacing: 10) {
                        ProcessStepCircle(state: task.stepState(for: index), color: task.priorityColor)
                            .frame(width: markerColumnWidth, height: rowHeight)

                        Text(action)
                            .font(.system(size: 14, weight: task.stepState(for: index) == .current ? .bold : .semibold))
                            .foregroundStyle(task.stepTextColor(for: index))
                            .strikethrough(task.stepState(for: index) == .completed, color: Color.refocusMuted.opacity(0.45))
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer(minLength: 0)
                    }
                    .frame(height: rowHeight)
                }
            }
        }
    }
}

private struct ProcessStepCircle: View {
    let state: ProcessStepState
    let color: Color

    private var markerColor: Color {
        color.opacity(0.82)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.96))
                .frame(width: 16, height: 16)

            switch state {
            case .completed:
                Circle()
                    .fill(markerColor)
            case .current:
                Circle()
                    .stroke(markerColor, lineWidth: 1.8)
                Circle()
                    .fill(markerColor)
                    .frame(width: 6.5, height: 6.5)
            case .upcoming:
                Circle()
                    .stroke(markerColor, lineWidth: 1.8)
            }
        }
        .frame(width: 12, height: 12)
    }
}

private struct AIChatView: View {
    let showImageParsingMock: Bool
    let showSharedImageMock: Bool
    let showTaskEditChatMock: Bool
    let showPriorityChatMock: Bool
    let showGeneratedImageTask: Bool

    @State private var message = ""
    @State private var showAttachmentPreview = true

    private var sharedImageBubbleIndex: Int? {
        (showSharedImageMock || showImageParsingMock) ? 3 : nil
    }

    private var bubbles: [ChatBubble] {
        var messages: [ChatBubble] = [
            ChatBubble(text: "할 일은 짧게 적어도 괜찮아요. 사진도 함께 볼 수 있어요.", isUser: false),
            ChatBubble(text: "오늘 저녁 닷넷 과제", isUser: true),
            ChatBubble(text: "닷넷 과제를 오늘 저녁 마감으로 잡을게요. 첫 행동은 요구사항 파일 열기예요.", isUser: false)
        ]

        if showSharedImageMock || showImageParsingMock {
            messages.append(ChatBubble(text: "이미지에서 운영체제 과제와 제출 정보를 찾았어요. 마감기한만 확인하면 업무로 만들 수 있어요. 언제까지인가요?", isUser: false))
        }

        if showGeneratedImageTask {
            messages.append(ChatBubble(text: "이번 주 금요일까지야", isUser: true))
            messages.append(ChatBubble(text: "운영체제 과제를 만들었어요. 첫 행동은 ‘제출 조건 확인하기’예요.", isUser: false))
        }

        if showTaskEditChatMock {
            messages.append(ChatBubble(text: "닷넷 과제 업무 중 풀이 구조 작성 부분을 예제 코드 먼저 확인하기로 수정해줘", isUser: true))
            messages.append(ChatBubble(text: "좋아요. ‘풀이 구조만 적기’를 ‘예제 코드 먼저 확인하기’로 바꿔둘게요. 그 다음 풀이 구조를 정리하면 돼요.", isUser: false))
        }

        if showPriorityChatMock {
            messages.append(ChatBubble(text: "운영체제보다 닷넷 과제가 더 급하지 않을까?", isUser: true))
            messages.append(ChatBubble(text: "맞아요. 닷넷은 오늘 저녁까지라 더 급해요. 운영체제는 길지만 금요일까지라, 지금은 닷넷 먼저 하고 운영체제는 제출 조건만 확인해도 좋아요. 뭐부터 할까요?", isUser: false))
            messages.append(ChatBubble(text: "그럼 닷넷 먼저 하자!", isUser: true))
            messages.append(ChatBubble(text: "좋아요. 닷넷을 가장 위에 두고, 지금 행동은 ‘예제 코드 먼저 확인하기’로 잡을게요.", isUser: false))
        }

        return messages
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            PocoBackground()

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Poco AI")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.refocusInk)
                        Text("부담 없이 적으면 순서와 첫 행동을 잡아줘요")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.refocusMuted)
                    }
                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.top, 22)
                .padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(Array(bubbles.enumerated()), id: \.element.id) { index, bubble in
                            if index == sharedImageBubbleIndex, showImageParsingMock && showAttachmentPreview {
                                ImageParsingPreviewCard()
                            }
                            ChatBubbleView(bubble: bubble)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .padding(.bottom, 72)
                }
            }

            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 138)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .black.opacity(0.62), location: 0.46),
                                .init(color: .black, location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(y: 34)
                    .allowsHitTesting(false)

                HStack(spacing: 10) {
                    Button {
                        showAttachmentPreview.toggle()
                    } label: {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.refocusViolet)
                            .frame(width: 52, height: 52)
                            .background(.white, in: Circle())
                            .shadow(color: .refocusShadow, radius: 16, y: 8)
                    }
                    .accessibilityLabel("이미지 첨부")

                    TextField("예: 과제 공지 사진 첨부", text: $message)
                        .font(.system(size: 15, weight: .medium))
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .background(.white, in: Capsule())
                        .shadow(color: .refocusShadow, radius: 16, y: 8)

                    Button { } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 52, height: 52)
                            .background(Color.refocusViolet, in: Circle())
                    }
                    .accessibilityLabel("전송")
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
            }
        }
    }
}

private struct ImageParsingPreviewCard: View {
    var body: some View {
        HStack {
            Spacer(minLength: 54)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 9) {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 42, height: 42)
                        .overlay {
                            Image(systemName: "doc.text.viewfinder")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                        }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("LMS_과제공지.png")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                        Text("이미지 첨부")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.78))
                    }
                }

                HStack(spacing: 6) {
                    MockToken(text: "운영체제")
                    MockToken(text: "제출")
                    MockToken(text: "마감 필요")
                }
            }
            .padding(13)
            .background(Color.refocusViolet, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.refocusViolet.opacity(0.18), radius: 14, y: 7)
        }
    }
}

private struct MockToken: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Color.refocusViolet)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.92), in: Capsule())
    }
}

private struct ChatBubbleView: View {
    let bubble: ChatBubble

    var body: some View {
        HStack {
            if bubble.isUser { Spacer(minLength: 44) }

            Text(bubble.text)
                .font(.system(size: 15, weight: .medium))
                .lineSpacing(3)
                .foregroundStyle(bubble.isUser ? .white : .refocusInk)
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .background(
                    bubble.isUser ? Color.refocusViolet : Color.white.opacity(0.94),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )

            if !bubble.isUser { Spacer(minLength: 44) }
        }
    }
}

private struct CalendarHistoryView: View {
    private let days = Array(1...31)
    private let activeDays: Set<Int> = [3, 6, 8, 12]

    var body: some View {
        ZStack {
            PocoBackground()

            VStack(alignment: .leading, spacing: 22) {
                Text("캘린더")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.refocusInk)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 12) {
                    ForEach(days, id: \.self) { day in
                        VStack(spacing: 5) {
                            Text("\(day)")
                                .font(.system(size: 15, weight: day == 12 ? .bold : .medium))
                                .foregroundStyle(day == 12 ? .white : .refocusInk)
                            Circle()
                                .fill(activeDays.contains(day) ? Color.refocusViolet : Color.clear)
                                .frame(width: 5, height: 5)
                        }
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(day == 12 ? Color.refocusViolet : Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("5월 12일 대화")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.refocusInk)

                    Text("닷넷 과제, 자료구조 복습, 팀플 회의 준비를 오늘의 실행 흐름으로 정리했어요.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.refocusMuted)
                        .lineSpacing(3)
                }
                .padding(18)
                .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                Spacer()
            }
            .padding(22)
        }
    }
}

private struct FocusSessionView: View {
    let task: FocusTask
    @State private var elapsedMinutes = 15
    @State private var showsRemainingTime = false

    private let targetMinutes = 25

    private var remainingMinutes: Int {
        max(targetMinutes - elapsedMinutes, 0)
    }

    private var overtimeMinutes: Int {
        max(elapsedMinutes - targetMinutes, 0)
    }

    private var timeValueText: String {
        if showsRemainingTime {
            return overtimeMinutes > 0 ? "+\(overtimeMinutes)분" : "\(remainingMinutes)분"
        }
        return "\(elapsedMinutes)분"
    }

    private var timeCaptionText: String {
        if showsRemainingTime {
            return overtimeMinutes > 0 ? "목표보다 더 하고 있어요" : "목표까지 남았어요"
        }
        return "지났어요"
    }

    var body: some View {
        ZStack {
            PocoBackground()

            VStack(spacing: 18) {
                VStack(spacing: 14) {
                    Label("집중 중", systemImage: "scope")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(task.tint)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(task.tint.opacity(0.1), in: Capsule())

                    Text(task.title)
                        .font(.system(size: 29, weight: .bold))
                        .foregroundStyle(Color.refocusInk)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    Text("남은 시간보다 지금 돌아온 흐름에 집중해요")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.refocusMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 0)

                Spacer(minLength: 10)

                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                        showsRemainingTime.toggle()
                    }
                } label: {
                    ZStack {
                        FocusAmbientRings(tint: task.tint)
                            .allowsHitTesting(false)
                            .zIndex(0)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 218, height: 218)
                            .shadow(color: task.tint.opacity(0.16), radius: 28, y: 14)
                            .zIndex(1)

                        VStack(spacing: 8) {
                            Text(timeValueText)
                                .font(.system(size: 46, weight: .bold))
                                .foregroundStyle(Color.refocusInk)
                                .contentTransition(.numericText())
                            Text(timeCaptionText)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.refocusMuted)
                                .multilineTextAlignment(.center)
                            Text("탭해서 전환")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(task.tint.opacity(0.72))
                        }
                        .zIndex(2)
                    }
                    .frame(width: 344, height: 344)
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("시간 표시 전환")

                Spacer(minLength: 18)

                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("지금 할 작은 행동")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.refocusMuted)
                        Text(task.nextStep)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.refocusInk)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                    HStack(spacing: 12) {
                        Button { } label: {
                            Label("잠깐 멈춤", systemImage: "pause.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SessionButtonStyle(background: .white, foreground: .refocusInk))

                        Button { } label: {
                            Label("완료", systemImage: "checkmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SessionButtonStyle(background: .refocusViolet, foreground: .white))
                    }
                }
                .padding(.bottom, 8)
            }
            .padding(22)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FocusAmbientRings: View {
    let tint: Color

    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                let size = CGFloat(132 + index * 36)
                let lineWidth = CGFloat(max(1.2, 9.0 - Double(index) * 1.25))
                let opacity = max(0.055, 0.34 - Double(index) * 0.045)
                let blurRadius = CGFloat(max(0, index - 1)) * 0.85

                Circle()
                    .stroke(tint.opacity(opacity), lineWidth: lineWidth)
                    .frame(width: size, height: size)
                    .blur(radius: blurRadius)
            }

            Circle()
                .fill(tint.opacity(0.035))
                .frame(width: 260, height: 260)
                .blur(radius: 14)
        }
    }
}

private struct FocusProgressRing: View {
    let progress: Double
    let tint: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.refocusLine, lineWidth: 14)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(tint, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

private struct ProgressRing: View {
    let progress: Double
    let tint: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.refocusLine, lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(tint, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Image(systemName: "play.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(tint)
        }
    }
}

private struct PocoBackground: View {
    var body: some View {
        LinearGradient(
            colors: [.refocusSurface, .refocusLilac.opacity(0.22), .white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct SessionButtonStyle: ButtonStyle {
    let background: Color
    let foreground: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(foreground)
            .padding(.vertical, 16)
            .background(background.opacity(configuration.isPressed ? 0.78 : 1), in: Capsule())
            .shadow(color: .refocusShadow, radius: 16, y: 8)
    }
}

private struct FocusTask: Identifiable, Hashable {
    let id: UUID
    let title: String
    let deadline: String
    let progress: Double
    let priority: String
    let nextStep: String
    let tint: Color
    let priorityLevel: Int
    let smallActions: [String]
    let currentStepIndex: Int

    init(
        id: UUID = UUID(),
        title: String,
        deadline: String,
        progress: Double,
        priority: String,
        nextStep: String,
        tint: Color,
        priorityLevel: Int = 2,
        smallActions: [String] = [],
        currentStepIndex: Int = 0
    ) {
        self.id = id
        self.title = title
        self.deadline = deadline
        self.progress = progress
        self.priority = priority
        self.nextStep = nextStep
        self.tint = tint
        self.priorityLevel = priorityLevel
        self.smallActions = smallActions
        self.currentStepIndex = currentStepIndex
    }

    var priorityLabel: String {
        switch priorityLevel {
        case 4...: "최우선"
        case 3: "높음"
        case 2: "보통"
        default: "여유"
        }
    }

    var priorityColor: Color {
        switch priorityLevel {
        case 4...: Color.refocusUrgent
        case 3: Color.refocusViolet
        case 2: Color.refocusLilac
        default: Color.refocusCalm
        }
    }

    var priorityIconName: String {
        switch priorityLevel {
        case 4...: "exclamationmark"
        case 3: "arrow.up"
        case 2: "minus"
        default: "leaf"
        }
    }

    func stepState(for index: Int) -> ProcessStepState {
        if index < currentStepIndex {
            return .completed
        } else if index == currentStepIndex {
            return .current
        } else {
            return .upcoming
        }
    }

    func stepTextColor(for index: Int) -> Color {
        switch stepState(for: index) {
        case .completed:
            Color.refocusMuted.opacity(0.42)
        case .current:
            Color.refocusInk
        case .upcoming:
            Color.refocusMuted.opacity(0.68)
        }
    }
}

private enum ProcessStepState {
    case completed
    case current
    case upcoming
}

private struct ChatBubble: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

private extension Color {
    static let refocusViolet = Color(red: 0.49, green: 0.38, blue: 0.86)
    static let refocusLilac = Color(red: 0.72, green: 0.62, blue: 0.95)
    static let refocusMint = Color(red: 0.37, green: 0.72, blue: 0.66)
    static let refocusCalm = Color(red: 0.56, green: 0.62, blue: 0.60)
    static let refocusUrgent = Color(red: 0.92, green: 0.34, blue: 0.45)
    static let refocusInk = Color(red: 0.16, green: 0.15, blue: 0.22)
    static let refocusMuted = Color(red: 0.47, green: 0.45, blue: 0.55)
    static let refocusSurface = Color(red: 0.97, green: 0.96, blue: 1.0)
    static let refocusLine = Color(red: 0.88, green: 0.86, blue: 0.94)
    static let refocusShadow = Color.black.opacity(0.08)
}

#Preview {
    ContentView()
}
