﻿&НаКлиенте
Процедура Накладная(Команда)
// Попытка создания COM-объекта Word
    ОбъектВорд = Новый COMОбъект("Word.Application");
    Если ОбъектВорд = Неопределено Тогда
        Сообщить("Не удалось запустить Microsoft Word.");
        Возврат;
    КонецЕсли;

    // Получение двоичных данных макета с сервера
    ДвоичныеДанныеМакета = ПолучитьДвоичныеДанныеМакетаНаСервере();
    Если ДвоичныеДанныеМакета = Неопределено Тогда
        Сообщить("Не удалось получить макет накладной.");
        ОбъектВорд.Quit();
        ОбъектВорд = Неопределено;
        Возврат;
    КонецЕсли;

    // Создание временного файла для шаблона
    ВременныйФайл = ПолучитьИмяВременногоФайла(".doc");
    ДвоичныеДанныеМакета.Записать(ВременныйФайл);

    // Открытие шаблона в Word
    ШаблонВорд = ОбъектВорд.Documents.Add(ВременныйФайл);
    Если ШаблонВорд = Неопределено Тогда
        Сообщить("Не удалось открыть шаблон документа.");
        ОбъектВорд.Quit();
        ОбъектВорд = Неопределено;
        Возврат;
    КонецЕсли;	
    Номер_наклТекст = Объект.Номер;
    ДатаТекст = Формат(Объект.Дата, "ДФ=dd.MM.yyyy");       
    ОтправительТекст = "Аптечный склад 'ФармаСклад'";
    Вид_отправителяТекст = "Распределение лекарств";
    ПолучательТекст = "Аптека " + Объект.Аптека;
    Вид_получателяТекст = "Реализация лекарственных средств";
    ОснованиеТекст = "приказ от " + ДатаТекст + " г.";
    КомуТекст = ПолучательТекст;
    Через_когоТекст = ОтправительТекст; 
    
    ШаблонВорд.Bookmarks("Номер_накл").Range.Text = Номер_наклТекст;
    ШаблонВорд.Bookmarks("Дата").Range.Text = ДатаТекст;
    ШаблонВорд.Bookmarks("Отправитель").Range.Text = ОтправительТекст;
    ШаблонВорд.Bookmarks("Вид_отправителя").Range.Text = Вид_отправителяТекст;
    ШаблонВорд.Bookmarks("Получатель").Range.Text = ПолучательТекст;
    ШаблонВорд.Bookmarks("Вид_получателя").Range.Text = Вид_получателяТекст;
    ШаблонВорд.Bookmarks("Основание").Range.Text = ОснованиеТекст;
    ШаблонВорд.Bookmarks("Кому").Range.Text = КомуТекст;
    ШаблонВорд.Bookmarks("Через_кого").Range.Text = Через_когоТекст;
    
    ТаблицаВорд = ШаблонВорд.Tables(4);
    общаяСумма = 0;

    // Собираем данные табличной части
    ДанныеТабличнойЧасти = Новый Массив;
    Для каждого строка из Объект.ПозицииЛекарств Цикл
        СтрокаДанных = Новый Структура;
        СтрокаДанных.Вставить("Лекарство", строка.Лекарство);
        СтрокаДанных.Вставить("Количество", строка.Количество);
        СтрокаДанных.Вставить("Цена", строка.Цена);
        СтрокаДанных.Вставить("Сумма", строка.Сумма);
        ДанныеТабличнойЧасти.Добавить(СтрокаДанных);
    КонецЦикла;

    // Получаем данные о лекарствах с сервера
    ДанныеЛекарств = ПолучитьДанныеЛекарств(ДанныеТабличнойЧасти);

    // Проходим по данным и заполняем таблицу
    Для Каждого ЛекарствоИзДанных Из ДанныеЛекарств Цикл
        ТаблицаВорд.Rows.Add();
        
		ТаблицаВорд.Cell(ТаблицаВорд.Rows.Count, 1).Range.Text = ЛекарствоИзДанных.Наименование;
		ТаблицаВорд.Cell(ТаблицаВорд.Rows.Count, 2).Range.Text = ЛекарствоИзДанных.Код;

        ТаблицаВорд.Cell(ТаблицаВорд.Rows.Count, 3).Range.Text = "упаковка";
        ТаблицаВорд.Cell(ТаблицаВорд.Rows.Count, 4).Range.Text = ЛекарствоИзДанных.Количество;
        ТаблицаВорд.Cell(ТаблицаВорд.Rows.Count, 5).Range.Text = ЛекарствоИзДанных.Количество;
        ТаблицаВорд.Cell(ТаблицаВорд.Rows.Count, 6).Range.Text = ЛекарствоИзДанных.Цена;
        ТаблицаВорд.Cell(ТаблицаВорд.Rows.Count, 7).Range.Text = ЛекарствоИзДанных.Сумма;
        
        общаяСумма = общаяСумма + ЛекарствоИзДанных.Сумма;
    КонецЦикла;

    Всего_отпущеноТекст = Объект.ПозицииЛекарств.Итог("Количество");
    На_суммуТекст = общаяСумма;     
    РазрешилТекст = "Шульгин С.С.";
    ОтпустилТекст = ПолучитьИнициалы(Объект.Провизор);
    Подпись_фармацевтТекст = ПолучитьФармацевта();
    
    ШаблонВорд.Bookmarks("Всего_отпущено").Range.Text = Всего_отпущеноТекст;
    ШаблонВорд.Bookmarks("На_сумму").Range.Text = На_суммуТекст;
    ШаблонВорд.Bookmarks("Разрешил").Range.Text = РазрешилТекст;
    ШаблонВорд.Bookmarks("Отпустил").Range.Text = ОтпустилТекст;
    ШаблонВорд.Bookmarks("Подпись_фармацевт").Range.Text = Подпись_фармацевтТекст;
    
    ОбъектВорд.Application.Visible = Истина;
    ОбъектВорд.Activate();
КонецПроцедуры

&НаСервере
Функция ПолучитьДанныеЛекарств(ДанныеТабличнойЧасти)
    ДанныеЛекарств = Новый Массив;
    
    Для каждого СтрокаДанных Из ДанныеТабличнойЧасти Цикл
        ЛекарствоСсылка = СтрокаДанных.Лекарство;
        
        Если НЕ ЛекарствоСсылка.Пустая() Тогда
            ЛекарствоОбъект = ЛекарствоСсылка.ПолучитьОбъект();
            СтруктураЛекарства = Новый Структура;
            СтруктураЛекарства.Вставить("Код", ЛекарствоОбъект.Код);
            СтруктураЛекарства.Вставить("Наименование", ЛекарствоОбъект.Наименование);
            СтруктураЛекарства.Вставить("Количество", СтрокаДанных.Количество);
            СтруктураЛекарства.Вставить("Цена", СтрокаДанных.Цена);
            СтруктураЛекарства.Вставить("Сумма", СтрокаДанных.Сумма);
            ДанныеЛекарств.Добавить(СтруктураЛекарства);
        КонецЕсли;
    КонецЦикла;
    
    Возврат ДанныеЛекарств;
КонецФункции

&НаСервере
Функция ПолучитьФармацевта()
    Пользователь = ПользователиИнформационнойБазы.НайтиПоИмени(Объект.Аптека.Код_Аптеки);
    Возврат ПолучитьИнициалы(Пользователь.ПолноеИмя);
КонецФункции

&НаСервере
Функция ПолучитьИнициалы(ПолноеИмя)
    ИмяЧасти = СтрРазделить(ПолноеИмя, " ");
    Если ИмяЧасти.Количество() >= 3 Тогда
        Фамилия = ИмяЧасти[0];
        Имя = ИмяЧасти[1];
        Отчество = ИмяЧасти[2];
        Возврат Фамилия + " " + Лев(Имя, 1) + "." + Лев(Отчество, 1) + ".";
    Иначе
        Возврат ПолноеИмя;
    КонецЕсли;
КонецФункции

&НаСервере
Функция ПолучитьДвоичныеДанныеМакетаНаСервере()
    Попытка
        Макет = ПолучитьОбщийМакет("Накладная71а");
        Возврат Макет;
    Исключение
        Сообщить("Ошибка получения макета: " + ОписаниеОшибки());
        Возврат Неопределено;
    КонецПопытки;
КонецФункции