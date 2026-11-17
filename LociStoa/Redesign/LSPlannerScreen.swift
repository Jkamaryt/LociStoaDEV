import SwiftUI

// LociStoa redesign: the Planner (opened from More, or from the home screen cards).
// Two views: Tasks (assignments, exams) and My classes (the student's own schedule).
// Nothing is pre-filled: each student adds their own classes and tasks.

struct LSPlannerScreen: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                LSBackButton(label: "Back") {
                    store.go(store.prevTab)
                }
                .padding(.vertical, -8)

                LSTitle(text: "Planner")

                LSSegmented(items: [("tasks", "Tasks"), ("times", "My classes")], selected: store.planMode.rawValue) { id in
                    if let mode = LSPlanMode(rawValue: id) {
                        store.planMode = mode
                    }
                }

                if store.planMode == .tasks {
                    LSTasksPane()
                } else {
                    LSClassesPane()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Tasks

struct LSTasksPane: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if store.tasks.isEmpty {
                LSEmptyCard(title: "No tasks yet", sub: "Add an assignment, exam, or reading to keep track of it here.")
            } else {
                LSCard(padding: 0) {
                    ForEach(Array(store.tasks.enumerated()), id: \.element.id) { index, task in
                        if index > 0 {
                            LSRule()
                        }
                        LSTaskRow(task: task)
                    }
                    .padding(.horizontal, 14)
                }
            }
            LSBigButton(title: "Add task", icon: "plus") {
                store.sheet = .addTask
            }
        }
    }
}

// MARK: - My classes

struct LSClassesPane: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        let rows = store.classRows
        VStack(alignment: .leading, spacing: 14) {
            if rows.isEmpty {
                LSEmptyCard(title: "No classes yet", sub: "Add each class once and your next one shows up on the Home screen.")
            } else {
                LSCard(padding: 0) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                        if index > 0 {
                            LSRule()
                        }
                        LSClassRowView(row: row)
                    }
                    .padding(.horizontal, 14)
                }
            }
            LSBigButton(title: "Add class", icon: "plus") {
                store.sheet = .addClass
            }
        }
    }
}

struct LSClassRowView: View {
    @EnvironmentObject var store: LSStore
    let row: LSClassRow

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                Text(row.code).font(.ls(16, .bold))
                Text(row.name)
                    .font(.ls(13))
                    .foregroundStyle(store.p.sub)
                Text(row.when)
                    .font(.ls(13.5, .semibold))
                    .monospacedDigit()
                    .padding(.top, 2)
                // If a learning center covers this subject, offer it right here.
                if let center = row.helpCenter {
                    Button {
                        store.openPeople(.tutor, center: center.id)
                    } label: {
                        Text("Need help? " + center.name)
                            .font(.ls(13.5, .bold))
                            .underline()
                            .foregroundStyle(store.p.word)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 12)
                            .padding(.bottom, 6)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(LSPressStyle())
                }
            }
            Spacer(minLength: 0)
            Button {
                store.removeClass(row.id)
            } label: {
                Image(systemName: "xmark")
                    .font(.ls(13, .bold))
                    .frame(width: 44, height: 44)
                    .background(store.p.tint)
                    .clipShape(Circle())
            }
            .buttonStyle(LSPressStyle())
            .accessibilityLabel("Remove " + row.code)
        }
        .padding(.vertical, 8)
        .frame(minHeight: 72)
    }
}

// MARK: - Add task panel

struct LSAddTaskSheet: View {
    @EnvironmentObject var store: LSStore
    @State private var type = "Assignment"
    @State private var course = ""

    private let types = ["Assignment", "Exam", "Project", "Reading", "Other"]

    /// The picked course, or the first choice if nothing is picked yet.
    private var pickedCourse: String {
        let options = store.courseOptions
        return options.contains(course) ? course : (options.first ?? "Other")
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                LSSheetHeader(title: "Add task")

                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Type")
                    LSChipRow {
                        ForEach(types, id: \.self) { name in
                            LSChip(label: name, on: type == name) {
                                type = name
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Course")
                    LSChipRow {
                        ForEach(store.courseOptions, id: \.self) { name in
                            LSChip(label: name, on: pickedCourse == name) {
                                course = name
                            }
                        }
                    }
                }

                LSBigButton(title: "Save task") {
                    store.addTask(type: type, course: pickedCourse)
                    store.sheet = nil
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 20)
        }
        .background(store.p.card)
    }
}

// MARK: - Add class panel

struct LSAddClassSheet: View {
    @EnvironmentObject var store: LSStore
    @State private var subject = ""         // the code picked from the list, e.g. "MIS"
    @State private var subjectText = ""     // what is typed in the box
    @State private var number = ""
    @State private var days: Set<String> = []
    @State private var start = LSStore.time(10, 0)
    @State private var end = LSStore.time(10, 50)
    @State private var location = ""
    @State private var error = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                LSSheetHeader(title: "Add class")

                // Subject: type a code or a name, then tap a match
                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Subject")
                    LSTextBox(placeholder: "Type a code or name, like MIS", text: $subjectText)
                        .onChange(of: subjectText) {
                            // Typing again un-picks the subject, unless the text is the one we just filled in.
                            if !subject.isEmpty && subjectText != subject + " · " + store.subjectName(subject) {
                                subject = ""
                            }
                        }
                    if subject.isEmpty {
                        let matches = store.subjectMatches(subjectText)
                        if !matches.isEmpty {
                            LSChipRow {
                                ForEach(matches) { match in
                                    LSChip(label: match.code + " · " + match.name, on: false) {
                                        subject = match.code
                                        subjectText = match.code + " · " + match.name
                                        error = ""
                                    }
                                }
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Course number")
                    LSTextBox(placeholder: "4000", text: $number)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                }

                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Days")
                    HStack(spacing: 8) {
                        ForEach(LSStore.days, id: \.letter) { day in
                            let on = days.contains(day.letter)
                            Button {
                                if on {
                                    days.remove(day.letter)
                                } else {
                                    days.insert(day.letter)
                                }
                                error = ""
                            } label: {
                                Text(day.short)
                                    .font(.ls(14, .bold))
                                    .foregroundStyle(on ? store.p.onSolid : store.p.ink)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(on ? store.p.solid : store.p.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(on ? store.p.solid : store.p.strong, lineWidth: 1.5)
                                    )
                            }
                            .buttonStyle(LSPressStyle())
                            .accessibilityAddTraits(on ? .isSelected : [])
                        }
                    }
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        LSCaps(text: "Starts")
                        DatePicker("Starts", selection: $start, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(alignment: .leading, spacing: 8) {
                        LSCaps(text: "Ends")
                        DatePicker("Ends", selection: $end, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Building and room (optional)")
                    LSTextBox(placeholder: "Fisher 135", text: $location)
                }

                if !error.isEmpty {
                    Text(error)
                        .font(.ls(14, .semibold))
                        .foregroundStyle(Color(lsHex: 0x8C1D18))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(lsHex: 0xFDECEA))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                LSBigButton(title: "Save class") {
                    let problem = store.addClass(
                        subject: subject,
                        typed: subjectText,
                        number: number,
                        days: days,
                        start: LSStore.hhmm(start),
                        end: LSStore.hhmm(end),
                        location: location
                    )
                    if let problem = problem {
                        error = problem
                    } else {
                        store.sheet = nil
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 20)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(store.p.card)
    }
}

/// A plain text box with a border, used in the forms.
struct LSTextBox: View {
    @EnvironmentObject var store: LSStore
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.ls(16))
            .autocorrectionDisabled(true)
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(store.p.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(store.p.strong, lineWidth: 1.5)
            )
    }
}
