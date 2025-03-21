﻿// Модуль объекта документа ЗаказНаСклад

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
    // Формируем идентификатор партии
    ИмяДокумента = "Партия " + Номер + " от " + Формат(Дата, "ДФ=dd.MM.yyyy");
    
    // Ищем документ ПартииЛекарств по реквизиту Заказ
    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ ПЕРВЫЕ 1
        |    ПартииЛекарств.Ссылка КАК Ссылка
        |ИЗ
        |    Документ.ПартииЛекарств КАК ПартииЛекарств
        |ГДЕ
        |    ПартииЛекарств.Заказ = &Заказ";
    Запрос.УстановитьПараметр("Заказ", ЭтотОбъект.Ссылка);
    Выборка = Запрос.Выполнить().Выбрать();
    
    Если Выборка.Следующий() Тогда
        ДокПартия = Выборка.Ссылка;
    Иначе
        ДокПартияОбъект = Документы.ПартииЛекарств.СоздатьДокумент();
        ДокПартияОбъект.Дата = ЭтотОбъект.Дата;
        ДокПартияОбъект.ИдентификаторПартии = ИмяДокумента; // Используем новый реквизит
        ДокПартияОбъект.Заказ = ЭтотОбъект.Ссылка; // Устанавливаем связь с заказом
        
        // Заполняем табличную часть СоставПартии
        Для Каждого СтрокаЗаказа Из ЭтотОбъект.ПозицииЛекарств Цикл
            НоваяСтрока = ДокПартияОбъект.СоставПартии.Добавить();
            НоваяСтрока.Лекарство = СтрокаЗаказа.Лекарство;
            НоваяСтрока.КоличествоНачальное = СтрокаЗаказа.Количество;
            
            // Расчёт срока годности
            ЗапросСрок = Новый Запрос;
            ЗапросСрок.Текст = 
                "ВЫБРАТЬ Лекарства.ТиповойСрокГодности КАК ТиповойСрокГодности 
                 |ИЗ Справочник.Лекарства КАК Лекарства 
                 |ГДЕ Лекарства.Ссылка = &Лекарство";
            ЗапросСрок.УстановитьПараметр("Лекарство", СтрокаЗаказа.Лекарство);
            ВыборкаСрок = ЗапросСрок.Выполнить().Выбрать();
            Если ВыборкаСрок.Следующий() И Не ПустаяСтрока(ВыборкаСрок.ТиповойСрокГодности) Тогда
                ЧислоМесяцев = Число(Лев(ВыборкаСрок.ТиповойСрокГодности, СтрНайти(ВыборкаСрок.ТиповойСрокГодности, " ") - 1)) * 12;
                НоваяСтрока.СрокГодности = ДобавитьМесяц(ДокПартияОбъект.Дата, ЧислоМесяцев);
            Иначе
                НоваяСтрока.СрокГодности = ДобавитьМесяц(ДокПартияОбъект.Дата, 24);
            КонецЕсли;
        КонецЦикла;
        
        // Записываем и проводим документ ПартииЛекарств
        ДокПартияОбъект.Записать(РежимЗаписиДокумента.Проведение);
        ДокПартия = ДокПартияОбъект.Ссылка;
    КонецЕсли;
    
    // Движения формируются только в документе ПартииЛекарств
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
    УникальныеЗаписи = Новый Соответствие();
    Для Каждого ТекСтрока Из ПозицииЛекарств Цикл
        Если УникальныеЗаписи.Получить(ТекСтрока.Лекарство) <> Неопределено Тогда
            Отказ = Истина;
            Сообщить("Лекарство '" + ТекСтрока.Лекарство + "' уже существует в документе.");
            Прервать;
        КонецЕсли;
        УникальныеЗаписи.Insert(ТекСтрока.Лекарство, Истина);
    КонецЦикла;

    Если ЭтотОбъект.ПозицииЛекарств.Количество() = 0 Тогда
        Отказ = Истина;
        Сообщить("Запись не может быть пустой.");
        Возврат;
    КонецЕсли;
КонецПроцедуры