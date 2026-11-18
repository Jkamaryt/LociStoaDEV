import SwiftUI

struct HomeworkPlannerView: View {
    @ObservedObject var toDoList = ToDoList()
    var store: LociStoaStore? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddItemView = false
    
    private var theme: LociTheme {
        store?.theme ?? .purple
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                (store?.effectiveBgColor ?? theme.bg).ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 14) {
                    if toDoList.items.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No tasks yet")
                                .font(LociFont.display(22, weight: .bold))
                                .foregroundColor(theme.ink)
                            Text("Add an assignment, exam, project, or reading to track your coursework and due dates.")
                                .font(LociFont.sans(14.5))
                                .foregroundColor(theme.sub)
                        }
                        .padding(22)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(theme.line, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        Spacer()
                    } else {
                        List {
                            ForEach($toDoList.items) { $item in
                                HStack(spacing: 12) {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.16)) {
                                            item.isCompleted.toggle()
                                        }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(item.isCompleted ? theme.accent : Color.clear)
                                                .frame(width: 24, height: 24)
                                            Circle()
                                                .stroke(item.isCompleted ? theme.accent : theme.check, lineWidth: 2)
                                                .frame(width: 24, height: 24)
                                            if item.isCompleted {
                                                LociIcon(kind: .check, size: 14, lineWidth: 3, color: .white)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.priority)
                                            .font(LociFont.sans(15.5, weight: .bold))
                                            .strikethrough(item.isCompleted)
                                            .foregroundColor(theme.ink)
                                        Text(item.classes)
                                            .font(LociFont.sans(13.5, weight: .semibold))
                                            .foregroundColor(theme.sub)
                                        if !item.description.isEmpty {
                                            Text(item.description)
                                                .font(LociFont.sans(13))
                                                .foregroundColor(theme.sub)
                                        }
                                    }
                                    Spacer()
                                    Text(item.dueDate, style: .date)
                                        .font(LociFont.sans(12, weight: .bold))
                                        .foregroundColor(theme.ink)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(theme.tint)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .padding(.vertical, 6)
                                .opacity(item.isCompleted ? 0.55 : 1.0)
                                .listRowBackground(Color.white)
                            }
                            .onMove { indices, newOffset in
                                toDoList.items.move(fromOffsets: indices, toOffset: newOffset)
                            }
                            .onDelete { indexSet in
                                toDoList.items.remove(atOffsets: indexSet)
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                    
                    Button(action: { showingAddItemView = true }) {
                        HStack(spacing: 8) {
                            LociIcon(kind: .plus, size: 18, lineWidth: 2.6, color: .white)
                            Text("Add New Task")
                                .font(LociFont.sans(16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(LociPressButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("TaskFlow Planner")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .sheet(isPresented: $showingAddItemView) {
                AddItemView(toDoList: toDoList, theme: theme)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                        dismiss()
                    }
                    .font(LociFont.sans(15, weight: .bold))
                    .foregroundColor(theme.ink)
                }
                
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .font(LociFont.sans(15, weight: .semibold))
                        .foregroundColor(theme.accent)
                }
                #endif
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddItemView = true }) {
                        LociIcon(kind: .plus, size: 18, lineWidth: 2.4, color: theme.accent)
                    }
                }
            }
        }
    }
}

struct HomeworkPlannerView_Previews: PreviewProvider {
    static var previews: some View {
        HomeworkPlannerView()
    }
}
