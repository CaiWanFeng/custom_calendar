# key api (关键 api)

## 1. weekday of the first day of this month (某年某月的第一天是星期几)

```dart
final firstDay = DateTime(year, month).weekday;
```

## 2. number of days of this month (某年某月有多少天)

```dart
final days = DateUtils.getDaysInMonth(year, month);
```

---

## demo：

![demo](demo.png)