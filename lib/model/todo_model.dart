class TODO {
  int? id;
  String task;
  String description;
  String date;
  String time;
  int checked;

  TODO({
    required this.date,
    required this.task,
    required this.description,
    required this.time,
    this.checked = 0,
    this.id,
  });

  factory TODO.fromDB({required Map data}) {
    return TODO(
      date: data['date'],
      task: data['task'],
      description: data['description'],
      time: data['time'],
      checked: data['checked'] as int,
      id: data['id'],
    );
  }
}
