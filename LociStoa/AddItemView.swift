import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    static let priorities = ["Assignment", "Exam", "Project", "Reading", "Other"]
    static let Class = ["MIS3100", "MIS4000", "HU2130", "HU2700", "Other"]
    
    @ObservedObject var toDoList: ToDoList
    var theme: LociTheme = .purple
    
    @State private var priority = "Assignment"
    @State private var classes = "MIS3100"
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.bg.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TASKFLOW PLANNER")
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                            Text("Add New Task")
                                .font(LociFont.display(30, weight: .heavy))
                                .foregroundColor(theme.ink)
                        }
                        
                        // 1. Type of Assignment Chips
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TYPE OF ASSIGNMENT")
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                            
                            LociFlowLayout(spacing: 8, lineSpacing: 8) {
                                ForEach(Self.priorities, id: \.self) { p in
                                    GavinChipButton(
                                        label: p,
                                        isSelected: priority == p,
                                        theme: theme
                                    ) {
                                        priority = p
                                    }
                                }
                            }
                        }
                        
                        // 2. Course Chips
                        VStack(alignment: .leading, spacing: 8) {
                            Text("COURSE")
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                            
                            LociFlowLayout(spacing: 8, lineSpacing: 8) {
                                ForEach(Self.Class, id: \.self) { c in
                                    GavinChipButton(
                                        label: c,
                                        isSelected: classes == c,
                                        theme: theme
                                    ) {
                                        classes = c
                                    }
                                }
                            }
                        }
                        
                        // 3. Description (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DESCRIPTION (OPTIONAL)")
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                            
                            TextField("Chapter 4 problems, lab report, etc.", text: $description)
                                .font(LociFont.sans(16))
                                .foregroundColor(theme.ink)
                                .padding(.horizontal, 14)
                                .frame(height: 52)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(theme.strong, lineWidth: 1.5)
                                )
                        }
                        
                        // 4. Due Date Picker Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DUE DATE")
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                            
                            DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                                .font(LociFont.sans(15, weight: .semibold))
                                .foregroundColor(theme.ink)
                                .tint(theme.accent)
                                .padding(.horizontal, 16)
                                .frame(height: 54)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(theme.strong, lineWidth: 1.5)
                                )
                        }
                        
                        // 5. Save Button
                        Button(action: {
                            saveTaskItem()
                        }) {
                            Text("Save Task")
                                .font(LociFont.sans(16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(theme.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(LociPressButtonStyle())
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add New Task")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTaskItem()
                    }
                    .font(LociFont.sans(15, weight: .bold))
                    .foregroundColor(theme.accent)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(LociFont.sans(15, weight: .bold))
                    .foregroundColor(theme.ink)
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Error"),
                message: Text("You must choose a task type and course before saving"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func saveTaskItem() {
        if priority != "Choose One" && classes != "Choose One" && !priority.isEmpty && !classes.isEmpty {
            let item = ToDoItem(
                id: UUID(),
                priority: priority,
                classes: classes,
                description: description,
                dueDate: dueDate,
                isCompleted: false
            )
            toDoList.items.append(item)
            dismiss()
        } else {
            showingAlert = true
        }
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView(toDoList: ToDoList())
    }
}
