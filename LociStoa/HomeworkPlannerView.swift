import SwiftUI

struct HomeworkPlannerView: View {
    @ObservedObject var toDoList = ToDoList()
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddItemView = false
    
    var body: some View {
        NavigationView {
            VStack{
                List {
                    ForEach(toDoList.items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.priority)
                                    .font(.headline)
                                Text(item.classes).font(.subheadline)
                                Text(item.description)
                            }
                            Spacer()
                            Text(item.dueDate, style: .date)
                        }
                    }
                    .onMove { indices, newOffset in
                        toDoList.items.move(fromOffsets: indices, toOffset: newOffset)
                    }
                    .onDelete { indexSet in
                        toDoList.items.remove(atOffsets: indexSet)
                    }
                }
            }
            .background(lociBackground)
            .accentColor(lociAccent)
            .scrollContentBackground(.hidden)
            .navigationTitle("TaskFlow Planner")
            .sheet(isPresented: $showingAddItemView, content: {
                AddItemView(toDoList: toDoList)
            })
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                #endif
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddItemView = true }) {
                        Image(systemName: "plus")
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
