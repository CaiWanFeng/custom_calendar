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

  List<DayModel> dayArray = [];

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
    return Expanded(
      child: GridView.builder(
        itemCount: _getDaysInMonth() + _getSpaceNum(),
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
    for (final dayModel in dayArray) {
      final array = dayModel.date.split('/');
      final modelYear = int.parse(array.first);
      final modelMonth = int.parse(array[1]);
      final modelDay = int.parse(array.last);
      if (_selectedYear == modelYear &&
          _selectedMonth == modelMonth &&
          day == modelDay) {
        // 展示后台返回的数据
        return GestureDetector(
          child: Container(
            alignment: Alignment.center,
            color: _hexColor(dayModel.bgColor),
            child: Text(
              day.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: _hexColor(dayModel.fontColor),
              ),
            ),
          ),
          onTap: () {
            print(dayModel.id);
          },
        );
      }
    }
    // 默认显示的cell
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: Text(
        day.toString(),
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
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
      dayArray = [model1, model2];
    });
  }

  /// 选择年
  void _selectYear(BuildContext context) {
    print('年');
    final yearArray = <int>[];
    for (int i = 2014; i <= 2028; i++) {
      yearArray.add(i);
    }
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: yearArray.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //横轴元素个数
              crossAxisCount: 3,
              //纵轴间距
              mainAxisSpacing: 2,
              //横轴间距
              crossAxisSpacing: 2,
              //子组件宽高长度比例
              childAspectRatio: 3.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              //Widget Function(BuildContext context, int index)
              return GestureDetector(
                onTap: () {
                  print('tap');
                  setState(() {
                    _selectedYear = yearArray[index];
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedYear == yearArray[index] ? Colors.yellow : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      yearArray[index].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              );
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
