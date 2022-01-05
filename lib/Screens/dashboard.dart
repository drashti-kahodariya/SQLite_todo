import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:sqlite_todo/Controller/todo_controller.dart';
import 'package:sqlite_todo/Helpers/constant.dart';
import 'package:sqlite_todo/Model/todoModel.dart';

final todoController = Get.put(TodoController());

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoController.createDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TODO APP"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return ModelBottomSheet();
            },
          );
        },
        backgroundColor: teal,
        child: const Icon(
          Icons.add,
          size: 35,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(
          () => todoController.todoList.length == 0
              ? CircularProgressIndicator()
              : ListView.separated(
                  itemCount: todoController.todoList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Dismissible(
                      background: Container(
                        color: Colors.green,
                      ),
                      key: ValueKey(index),
                      onDismissed: (DismissDirection direction) {
                        todoController.delete(
                            id: todoController.todoList[index].id);
                      },
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return ModelBottomSheet(
                                todoDetail: todoController.todoList[index],
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 12.h,
                          color: Colors.brown,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(
                                  "${todoController.todoList[index].id}",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${todoController.todoList[index].title}",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      "${todoController.todoList[index].description}",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      "${todoController.todoList[index].date}",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: 40.w,
                                ),
                                Icon(Icons.auto_delete,
                                    size: 30, color: Colors.redAccent),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(height: 2.h);
                  },
                ),
        ),
      ),
    );
  }
}

class ModelBottomSheet extends StatefulWidget {
  ModelBottomSheet({Key? key, this.todoDetail}) : super(key: key);
  final TodoModel? todoDetail;
  @override
  _ModelBottomSheetState createState() => _ModelBottomSheetState();
}

class _ModelBottomSheetState extends State<ModelBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    if (widget.todoDetail != null) {
      _titleController.text = widget.todoDetail!.title!;
      _descriptionController.text = widget.todoDetail!.description!;
      _dateController.text = widget.todoDetail!.date!;
    }
  }

  void dispose() {
    super.dispose();
    _titleController.clear();
    _descriptionController.clear();
    _dateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: 50.h,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _titleController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter tittle";
                        }
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          labelText: "Tittle"),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter description";
                        }
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          labelText: "Description"),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    TextFormField(
                      readOnly: true,
                      controller: _dateController,
                      onTap: () => _selectDate(),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Select Date";
                        }
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          labelText: "Date"),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (formkey.currentState!.validate()) {
                          Get.back();
                          if (widget.todoDetail != null) {
                            todoController.updateTodo(TodoModel(
                                id: widget.todoDetail!.id,
                                title: _titleController.text,
                                description: _descriptionController.text,
                                date: _dateController.text));
                          } else {
                            todoController.addData(
                                title: _titleController.text,
                                description: _descriptionController.text,
                                date: _dateController.text);
                          }
                        }
                      },
                      child: Container(
                        height: 6.h,
                        width: 15.h,
                        decoration: BoxDecoration(
                          color: teal,
                        ),
                        child: Center(
                            child: Text(
                          widget.todoDetail == null ? "ADD" : "UPDATE",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
    _dateController.text = DateFormat.yMMMd().format(selectedDate);
  }
}
