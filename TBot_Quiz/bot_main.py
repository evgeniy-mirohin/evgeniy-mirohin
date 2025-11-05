#@title Полный код бота для самоконтроля
import aiosqlite
import asyncio
import logging
from aiogram import Bot, Dispatcher, types
from aiogram.filters.command import Command
from aiogram.utils.keyboard import InlineKeyboardBuilder, ReplyKeyboardBuilder
from aiogram import F
from quiz import quiz_data
from SQL_quiz import *
# Включаем логирование, чтобы не пропустить важные сообщения
logging.basicConfig(level=logging.INFO)

# Замените "YOUR_BOT_TOKEN" на ваш токен
API_TOKEN = 'YOUR_BOT_TOKEN'

# Объект бота
bot = Bot(token=API_TOKEN)
# Диспетчер
dp = Dispatcher(bot=bot)


def generate_options_keyboard(answer_options):
    builder = InlineKeyboardBuilder()
    for i in range(len(answer_options)):
        builder.add(types.InlineKeyboardButton(
        text=answer_options[i],
        callback_data = str(i))
        )   
    builder.adjust(1)
    return builder.as_markup()

@dp.callback_query(F.data)
async def right_answer(callback: types.CallbackQuery):
    await callback.bot.edit_message_reply_markup(
        chat_id=callback.from_user.id,
        message_id=callback.message.message_id,
        reply_markup=None
    )
    action = int(callback.data)
    # получаю последний вопрос из БД
    current_question_index = await get_quiz_index(callback.from_user.id)
    correct_option = quiz_data[current_question_index]['correct_option']

    if quiz_data[current_question_index]['options'][action] == quiz_data[current_question_index]['options'][correct_option]:
        await callback.message.answer(f"ответ: {quiz_data[current_question_index]['options'][action]} верный")
        result = await get_quiz_result(callback.from_user.id)
        await update_quiz_result(callback.from_user.id, result+1)
    else:
        await callback.message.answer(f"ответ: {quiz_data[current_question_index]['options'][action]} неверный. Правильный ответ: {quiz_data[current_question_index]['options'][correct_option]}")
  # Обновление номера текущего вопроса в базе данных
    current_question_index += 1
    await update_quiz_index(callback.from_user.id, current_question_index)
    if current_question_index < len(quiz_data):
        await get_question(callback.message, callback.from_user.id)
    else:
        await callback.message.answer("Это был последний вопрос. Квиз завершен!")
        result = await get_quiz_result(callback.from_user.id)
        await callback.message.answer(f"ваш результат: {result} правильных ответов")
        await update_quiz_result(callback.from_user.id,0)
        await update_quiz_index(callback.from_user.id, 0)


# Хэндлер на команду /start
@dp.message(Command("start"))
async def cmd_start(message: types.Message):
    builder = ReplyKeyboardBuilder()
    builder.add(types.KeyboardButton(text="Начать игру"))
    await message.answer("Добро пожаловать в квиз!", reply_markup=builder.as_markup(resize_keyboard=True))

async def get_question(message, user_id):
     # Получение текущего вопроса из словаря состояний пользователя
    current_question_index = await get_quiz_index(user_id)
    #correct_index = quiz_data[current_question_index]['correct_option']
    opts = quiz_data[current_question_index]['options']
    
    kb = generate_options_keyboard(opts)
    await message.answer(f"{quiz_data[current_question_index]['question']}", reply_markup=kb)

async def new_quiz(message):
    user_id = message.from_user.id
    result = await get_quiz_index(user_id)
    if result == 0:
        await new_quiz_index(message.from_user.id, 0)
        await update_quiz_result(message.from_user.id,0)
    await get_question(message, user_id)


# Хэндлер на команду /quiz
@dp.message(F.text=="Начать игру")
@dp.message(Command("quiz"))
async def cmd_quiz(message: types.Message):
    await message.answer(f"Давайте начнем квиз!")
    await new_quiz(message)

async def main():

    # Запускаем создание таблицы базы данных
    await create_table()
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
