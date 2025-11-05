# Структура квиза
quiz_data = [
    {
        'question': 'Что такое Python?',
        'options': ['Язык программирования', 'Тип данных', 'Музыкальный инструмент', 'Змея на английском'],
        'correct_option': 0
    },
    {
        'question': 'Какой тип данных используется для хранения целых чисел?',
        'options': ['int', 'float', 'str', 'natural'],
        'correct_option': 0
    },
    {
        'question': 'Что выведет следующий код?\nprint(type([]))',
        'options': ['<class "list">', 'list', '<list>', '[]'],
        'correct_option': 0
    },
    {
        'question': 'Какой результат будет у выражения: "Hello" * 3?',
        'options': ['Hello3', 'HelloHelloHello', 'Hello', '"Hello*3'],
        'correct_option': 1
    },
    {
        'question': 'Что делает оператор pass в Python?',
        'options': ['Завершает выполнение программы', 'Заменяет недостающий или пустой блок кода', 'Вызывает исключение', 'Воспроизводит ошибку'],
        'correct_option': 1
    },
        {
        'question': 'Какой из вариантов является корректной записью функции в Python?',
        'options': ['def myFunction[]:', 'function myFunction():', 'def myFunction():', 'function myFunction[]:'],
        'correct_option': 2
    },
    {
        'question': 'Что такое генератор в Python?',
        'options': ['Объект, создающий последовательность значений по мере необходимости', 'Модуль для работы с файлами', 'Специальная функция for', 'Итератор, возвращающий только числа'],
        'correct_option': 0
    },
    {
        'question': 'Какая команда используется для импорта модуля в Python?',
        'options': ['include', 'import', 'using', 'require'],
        'correct_option': 1
    },
    {
        'question': 'Какой будет результат выполнения: len("Python")?',
        'options': ['4', '5', '6', 'Ошибка'],
        'correct_option': 2
    },
    {
        'question': 'Что выведет код?:\nx = [1, 2, 3]\nx.append([4, 5])\nprint(x)',
        'options': ['[1, 2, 3, 4, 5]', '[1, 2, 3, [4, 5]]', '[1, 2, 3, 4, 5, [4, 5]]', '[1, 2, 3, "4, 5"]'],
        'correct_option': 1
    },
]

if __name__ == '__main__':
    print(len(quiz_data))
