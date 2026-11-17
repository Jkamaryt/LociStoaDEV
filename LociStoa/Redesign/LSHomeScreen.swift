import SwiftUI

// LociStoa redesign: the Home tab (the dashboard).
// Each block on this screen is a "widget". The student turns widgets on and off in More.

struct LSHomeScreen: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    LSTitle(text: "Dashboard")
                    Text(store.todayText)
                        .font(.ls(15, .semibold))
                        .foregroundStyle(store.p.sub)
                        .padding(.top, 4)
                }

                if store.widgetOn("next") {
                    LSNextClassCard()
                }
                if store.widgetOn("cal") {
                    LSWeekCard()
                }
                if store.widgetOn("due") {
                    LSDueSoonCard()
                }
                if store.widgetOn("links") {
                    LSQuickLinksGrid()
                }
                if store.widgetOn("help") {
                    LSHelpChips()
                }
                if store.widgetOn("saved") && !store.favPeople.isEmpty {
                    LSSavedPeople()
                }
                if store.widgetOn("org"), let org = store.orgOfTheDay {
                    LSOrgOfTheDay(org: org)
                }
                if store.widgetOn("places") {
                    LSShortcuts()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Next class

struct LSNextClassCard: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let next = store.nextClass {
                VStack(alignment: .leading, spacing: 4) {
                    Text(next.label.uppercased())
                        .font(.ls(12, .bold))
                        .tracking(1)
                        .foregroundStyle(store.p.h1)
                    Text(next.code)
                        .font(.ls(32, .heavy))
                    Text(next.line)
                        .font(.ls(16, .medium))
                        .monospacedDigit()
                        .foregroundStyle(store.p.h2)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.classes.isEmpty ? "Add your classes" : "No classes coming up")
                        .font(.ls(28, .heavy))
                    Text(store.classes.isEmpty
                         ? "Build your schedule and your next class shows up here."
                         : "Nothing on your schedule this week.")
                        .font(.ls(15))
                        .foregroundStyle(store.p.h2)
                }
            }

            Button {
                store.openPlanner(.times)
            } label: {
                HStack(spacing: 6) {
                    Text("My classes").font(.ls(14, .bold))
                    Image(systemName: "chevron.right").font(.ls(12, .bold))
                }
                .foregroundStyle(store.p.ink)
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(store.p.card)
                .clipShape(Capsule())
            }
            .buttonStyle(LSPressStyle())
        }
        .foregroundStyle(store.p.heroFg)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(store.p.heroBg)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

// MARK: - This week

struct LSWeekCard: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        LSCard(radius: 26) {
            HStack {
                LSHeading(text: "This week")
                Spacer(minLength: 0)
                Button {
                    store.openPlanner(.times)
                } label: {
                    Text("Edit classes")
                        .font(.ls(14, .semibold))
                        .underline()
                        .foregroundStyle(store.p.ink)
                }
            }

            HStack(spacing: 6) {
                ForEach(store.weekDays) { day in
                    let on = store.calSelected == day.id
                    Button {
                        store.calDay = day.id
                    } label: {
                        VStack(spacing: 1) {
                            Text(day.top).font(.ls(11.5, .bold))
                            Text(String(day.num))
                                .font(.ls(20, .heavy))
                                .monospacedDigit()
                            Text(day.dots)
                                .font(.ls(14))
                                .frame(height: 10)
                        }
                        .foregroundStyle(on ? store.p.onSolid : store.p.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background(on ? store.p.solid : store.p.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(on ? store.p.solid : store.p.strong, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(LSPressStyle())
                    .accessibilityLabel(day.spoken)
                    .accessibilityAddTraits(on ? .isSelected : [])
                }
            }
            .padding(.top, 12)

            if store.calList.isEmpty {
                LSRule().padding(.top, 12)
                Text(store.calEmptyText)
                    .font(.ls(14))
                    .foregroundStyle(store.p.sub)
                    .padding(.top, 10)
            } else {
                VStack(spacing: 0) {
                    ForEach(store.calList) { row in
                        LSRule()
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(row.code).font(.ls(15, .bold))
                                Text(row.name).font(.ls(12.5)).foregroundStyle(store.p.sub)
                            }
                            Spacer(minLength: 0)
                            Text(row.time)
                                .font(.ls(13.5, .semibold))
                                .monospacedDigit()
                        }
                        .frame(minHeight: 52)
                    }
                }
                .padding(.top, 12)
            }
        }
    }
}

// MARK: - Due soon

struct LSDueSoonCard: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        LSCard(radius: 26) {
            HStack {
                LSHeading(text: "Due soon")
                Spacer(minLength: 0)
                Button {
                    store.openPlanner(.tasks)
                } label: {
                    Text("Open planner")
                        .font(.ls(14, .semibold))
                        .underline()
                        .foregroundStyle(store.p.ink)
                }
            }
            .padding(.bottom, 8)

            if store.dueSoon.isEmpty {
                LSRule()
                VStack(alignment: .leading, spacing: 4) {
                    Text("You're all caught up").font(.ls(15, .semibold))
                    Text("New tasks you add in the planner show up here.")
                        .font(.ls(13))
                        .foregroundStyle(store.p.sub)
                }
                .padding(.top, 14)
                .padding(.bottom, 4)
            } else {
                ForEach(store.dueSoon) { task in
                    LSRule()
                    LSTaskRow(task: task)
                }
            }
        }
    }
}

/// One task with its round checkbox. Used here and in the planner.
struct LSTaskRow: View {
    @EnvironmentObject var store: LSStore
    let task: LSTask

    var body: some View {
        HStack(spacing: 12) {
            Button {
                store.toggleTask(task.id)
            } label: {
                ZStack {
                    Circle()
                        .fill(task.done ? store.p.accentInk : Color.clear)
                    Circle()
                        .stroke(task.done ? store.p.accentInk : store.p.check, lineWidth: 2)
                    if task.done {
                        Image(systemName: "checkmark")
                            .font(.ls(12, .heavy))
                            .foregroundStyle(store.p.onAccentInk)
                    }
                }
                .frame(width: 24, height: 24)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(LSPressStyle())
            .padding(.leading, -8)
            .accessibilityLabel((task.done ? "Mark not done: " : "Mark done: ") + task.type + ", " + task.course)

            VStack(alignment: .leading, spacing: 0) {
                Text(task.type)
                    .font(.ls(15, .semibold))
                    .strikethrough(task.done)
                Text(task.course)
                    .font(.ls(13))
                    .foregroundStyle(store.p.sub)
            }
            Spacer(minLength: 0)
            Text(task.due)
                .font(.ls(12, .bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(store.p.tint)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .frame(minHeight: 60)
        .opacity(task.done ? 0.55 : 1.0)
    }
}

// MARK: - Quick links

struct LSQuickLinksGrid: View {
    @EnvironmentObject var store: LSStore

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LSHeading(text: "Quick links")
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(store.data.links) { link in
                    if let url = URL(string: link.url) {
                        Link(destination: url) {
                            HStack(spacing: 8) {
                                Text(link.label)
                                    .font(.ls(14.5, .bold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Spacer(minLength: 0)
                                Image(systemName: "arrow.up.right").font(.ls(13, .bold))
                            }
                            .foregroundStyle(store.p.ink)
                            .padding(.horizontal, 14)
                            .frame(height: 56)
                            .background(store.p.card)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(store.p.line, lineWidth: 1)
                            )
                        }
                        .accessibilityHint("Opens in browser")
                    }
                }
            }
        }
    }
}

// MARK: - Get help with

struct LSHelpChips: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LSHeading(text: "Get help with")
            LSChipRow {
                ForEach(LSStore.helpChips, id: \.label) { chip in
                    LSChip(label: chip.label, on: false) {
                        store.openOffice(chip.office)
                    }
                }
            }
        }
    }
}

// MARK: - Saved people

struct LSSavedPeople: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LSHeading(text: "Saved people")
            LSChipRow {
                ForEach(store.favPeople) { person in
                    Button {
                        store.openContact(person)
                    } label: {
                        HStack(spacing: 10) {
                            Text(person.initials)
                                .font(.ls(13, .bold))
                                .foregroundStyle(store.p.onDeep)
                                .frame(width: 40, height: 40)
                                .background(store.p.deep)
                                .clipShape(Circle())
                            Text(person.name).font(.ls(14, .semibold))
                        }
                        .padding(.leading, 6)
                        .padding(.trailing, 16)
                        .frame(height: 52)
                        .background(store.p.card)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(store.p.line, lineWidth: 1))
                    }
                    .buttonStyle(LSPressStyle())
                }
            }
        }
    }
}

// MARK: - Student org of the day

struct LSOrgOfTheDay: View {
    @EnvironmentObject var store: LSStore
    let org: LSOrg

    /// The description, cut to about 150 characters at a word break.
    private var shortDesc: String {
        guard org.desc.count > 150 else { return org.desc }
        var cut = String(org.desc.prefix(150))
        if let lastSpace = cut.lastIndex(of: " ") {
            cut = String(cut[..<lastSpace])
        }
        return cut + "…"
    }

    var body: some View {
        LSCard(radius: 26) {
            LSCaps(text: "Student org of the day")
            HStack(spacing: 12) {
                LSOrgLogo(org: org, size: 48, corner: 10)
                VStack(alignment: .leading, spacing: 2) {
                    LSHeading(text: org.name)
                    Text(org.category)
                        .font(.ls(13, .semibold))
                        .foregroundStyle(store.p.sub)
                }
            }
            .padding(.top, 6)
            Text(shortDesc)
                .font(.ls(14))
                .padding(.top, 6)
            HStack(spacing: 8) {
                Button {
                    store.openPeople(.orgs, org: org.id)
                } label: {
                    Text("View")
                        .font(.ls(14, .bold))
                        .foregroundStyle(store.p.onAccent)
                        .padding(.horizontal, 18)
                        .frame(height: 44)
                        .background(store.p.accent)
                        .clipShape(Capsule())
                }
                .buttonStyle(LSPressStyle())
                Button {
                    store.openPeople(.orgs)
                } label: {
                    Text("All orgs")
                        .font(.ls(14, .bold))
                        .foregroundStyle(store.p.ink)
                        .padding(.horizontal, 18)
                        .frame(height: 44)
                        .background(store.p.tint)
                        .clipShape(Capsule())
                }
                .buttonStyle(LSPressStyle())
            }
            .padding(.top, 14)
        }
    }
}

// MARK: - People & places

struct LSShortcuts: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LSHeading(text: "People & places")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(LSStore.tools.prefix(4))) { tool in
                        Button {
                            store.run(tool)
                        } label: {
                            VStack(alignment: .leading, spacing: 0) {
                                Image(systemName: tool.icon)
                                    .font(.ls(17, .semibold))
                                    .frame(width: 38, height: 38)
                                    .background(store.p.tint)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                Spacer(minLength: 0)
                                Text(tool.label).font(.ls(15, .bold))
                                Text(tool.sub)
                                    .font(.ls(12.5))
                                    .foregroundStyle(store.p.sub)
                                    .padding(.top, 2)
                            }
                            .padding(14)
                            .frame(width: 146, height: 118, alignment: .leading)
                            .background(store.p.card)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(store.p.line, lineWidth: 1)
                            )
                        }
                        .buttonStyle(LSPressStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }
}
