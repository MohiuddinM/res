Result class like many other but this one can return void type too, and does not need a "Unit" type

## Features

- Prevent app crashes

## Usage

### Wrap a function that can throw an error:
```dart
Result.of(
  () {
    final n = Random().nextInt(10);

    if (n < 5) {
      throw RangeError(n);
    }

    return n;
  },
  error: (e, s) => e.toString(),
);
```

### Or wrap a future that can throw an error:
```dart
Result.ofFuture(
  functionThatCanThrowError(),
  error: (e, s) => e.toString(),
);
```


### Or catch error manually
```dart
Future<int> functionThatCanThrowError() async {
  final n = Random().nextInt(10);

  if (n < 5) {
    throw RangeError(n);
  }

  return n;
}

Future<Result<int, String>> functionThatDoesNotThrow() async {
  try {
    return Result.ok(await functionThatCanThrowError());
  } catch (e, s) {
    return Result.err(e.toString() + s.toString());
  }
}

void main() async {
  final result = await functionThatDoesNotThrow();

  if (result.isError) {
    return print('Error');
  }

  return print(result.value);
}
```
