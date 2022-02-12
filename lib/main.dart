import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  /// 后台返回的数据
  List<DayModel> _dayArray = [];

  /// 处于选中状态的日期
  List<DateModel> _selectedDateArray = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('日历'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSelectYearView(context),
              _buildChangeMonthView(context),
            ],
          ),
          const SizedBox(height: 20),
          _buildWeekView(context),
          const SizedBox(height: 10),
          _buildGridView(context),
        ],
      ),
    );
  }

  /// 选择年view
  Widget _buildSelectYearView(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectYear(context),
      child: Container(
        padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
          child: Row(
            children: [
              Text(
                '$_selectedYear年',
              ),
              Text(
                '$_selectedMonth月',
              ),
              const Icon(CupertinoIcons.down_arrow),
            ],
          ),
        ),
      ),
    );
  }

  /// 加减月份的view
  Widget _buildChangeMonthView(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: _minusMonth,
          icon: const Icon(
            CupertinoIcons.minus_circled,
            color: Colors.black,
            size: 24,
          ),
        ),
        IconButton(
          onPressed: _addMonth,
          icon: const Icon(
            CupertinoIcons.add,
            color: Colors.black,
            size: 24,
          ),
        ),
      ],
    );
  }

  /// 星期view
  Widget _buildWeekView(BuildContext context) {
    final weeks = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(weeks.length, (index) {
        return Expanded(
          child: Text(
            weeks[index],
            textAlign: TextAlign.center,
          ),
        );
      }),
    );
  }

  /// 日view
  Widget _buildGridView(BuildContext context) {
    return GestureDetector(
      onPanEnd: (DragEndDetails s) {
        print('end');
        if (s.velocity.pixelsPerSecond.dx > 0) {
          print('向右扫');
          setState(() {
            _minusMonth();
          });
        }
        if (s.velocity.pixelsPerSecond.dx < 0) {
          print('向左扫');
          setState(() {
            _addMonth();
          });
        }
        print(s.velocity);
      },
      child: GridView.builder(
        itemCount: _getDaysInMonth() + _getSpaceNum(),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //横轴元素个数
          crossAxisCount: 7,
          //纵轴间距
          mainAxisSpacing: 2,
          //横轴间距
          crossAxisSpacing: 2,
          //子组件宽高长度比例
          childAspectRatio: 1.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          //Widget Function(BuildContext context, int index)
          return Visibility(
            visible: index >= _getSpaceNum(),
            child: _buildCell(day: index - _getSpaceNum() + 1),
          );
        },
      ),
    );
  }

  /// 创建cell
  Widget _buildCell({
    required int day,
  }) {
    final cellDate = DateModel();
    cellDate.year = _selectedYear;
    cellDate.month = _selectedMonth;
    cellDate.day = day;

    bool isSelected = false;
    if (_selectedDateArray.contains(cellDate)) {
      isSelected = true;
    }

    for (final model in _dayArray) {
      final array = model.date.split('/');
      final modelYear = int.parse(array.first);
      final modelMonth = int.parse(array[1]);
      final modelDay = int.parse(array.last);
      // 有后台数据的cell
      if (_selectedYear == modelYear &&
          _selectedMonth == modelMonth &&
          day == modelDay) {
        // 展示后台返回的数据
        return GestureDetector(
          child: Container(
            alignment: Alignment.center,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: _hexColor(model.bgColor),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 2,
                color: isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.transparent,
              ),
            ),
            child: Text(
              day.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: _hexColor(model.fontColor),
              ),
            ),
          ),
          onTap: () {
            print(model.id);
            _clickCell(day);
          },
        );
      }
    }

    // 没有后台数据的cell
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent,
          ),
        ),
        child: Text(
          day.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
      onTap: () => _clickCell(day),
    );
  }

  /// 模拟请求数据
  void _loadData() {
    DayModel model1 = DayModel();
    model1.fontColor = '#000000';
    model1.date = '2022/01/01';
    model1.bgColor = '#FF3CAA';
    model1.id = '111';

    DayModel model2 = DayModel();
    model2.fontColor = '#ff0055';
    model2.date = '2022/01/02';
    model2.bgColor = '#aaaaaa';
    model2.id = '111';

    setState(() {
      _dayArray = [model1, model2];
    });
  }

  /// 点击cell
  void _clickCell(int day) {
    final date = DateModel();
    date.year = _selectedYear;
    date.month = _selectedMonth;
    date.day = day;
    setState(() {
      if (_selectedDateArray.contains(date)) {
        _selectedDateArray.remove(date);
      } else {
        if (_selectedDateArray.isEmpty) {
          _selectedDateArray.add(date);
        } else {
          // 选中状态的cell只能有一个
          _selectedDateArray = [];
          _selectedDateArray.add(date);
        }
      }
    });
  }

  /// 选择年
  void _selectYear(BuildContext context) {
    print('年');
    final yearArray = <int>[];
    for (int i = 1998; i <= 2050; i++) {
      yearArray.add(i);
    }
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: CupertinoDatePicker(
            initialDateTime: DateTime(_selectedYear, _selectedMonth),
            mode: CupertinoDatePickerMode.date,
            onDateTimeChanged: (DateTime value) {
              setState(() {
                _selectedYear = value.year;
                _selectedMonth = value.month;
              });
            },
          ),
        );
      },
    );
  }

  /// 月 - 1
  void _minusMonth() {
    setState(() {
      _selectedMonth--;
      if (_selectedMonth <= 0) {
        _selectedMonth = 12;
      }
    });
  }

  /// 月 + 1
  void _addMonth() {
    setState(() {
      _selectedMonth++;
      if (_selectedMonth > 12) {
        _selectedMonth = 1;
      }
    });
    final date1 = DateModel();
    date1.year = 11;
    date1.month = 11;
    date1.day = 11;

    final date2 = DateModel();
    date2.year = 11;
    date2.month = 11;
    date2.day = 11;

    final date3 = DateModel();
    date3.year = 11;
    date3.month = 11;
    date3.day = 11;

    final arr = [date1, date2];
    arr.remove(date3);
    print(arr.length);

    // assert(date1 == date2);
    // if (date1 == date2) {
    //   print('相等');
    // } else {
    //   print('不相等');
    // }
  }

  /// 当前月有多少天
  int _getDaysInMonth() {
    return DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
  }

  /// 前面空几个格子
  int _getSpaceNum() {
    final weekday = DateTime(_selectedYear, _selectedMonth).weekday;
    return weekday % 7;
  }

  /// 将后台返回的 #ff0000 转化为 flutter color
  Color _hexColor(String color) {
    return Color(int.parse(color.replaceAll('#', '0xff')));
  }
}

class DayModel {
  late String fontColor;
  late String date;
  late String bgColor;
  late String id;
}

class DateModel {
  int year = 0;
  int month = 0;
  int day = 0;

  // 重写操作符
  @override
  bool operator ==(Object other) {
    final otherDate = other as DateModel;
    if (year == otherDate.year &&
        month == otherDate.month &&
        day == otherDate.day) {
      return true;
    }
    return false;
  }

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ day.hashCode;
}
