﻿&НаКлиенте
Процедура СсылкаНаФотографиюНажатие(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = ложь;
	Режим = РежимДиалогаВыбораФайла.Открытие;
	ДиалогОткрытия = новый ДиалогВыбораФайла(Режим);
	ДиалогОткрытия.ПолноеИмяФайла = "";  
	Фильтр = "Файл Jpg(*.jpg)|*.jpg|Файл Png(*.png)|*.png|Файл Jpeg(*.jpeg;*.jpg)|*.jpeg;*.jpg";
	ДиалогОткрытия.Фильтр = Фильтр;
	ДиалогОткрытия.МножественныйВыбор = ложь;     
	ДиалогОткрытия.Заголовок = "Выберете файл для загрузки";
	ОписаниеОповещения = новый ОписаниеОповещения("ПослеЗагрузкиФайла", ЭтаФорма);
	ДиалогОткрытия.Показать(ОписаниеОповещения);
КонецПроцедуры         

&НаКлиенте
Процедура ПослеЗагрузкиФайла(ВыбранныйФайл,ДопПараметр) Экспорт
Если ВыбранныйФайл = Неопределено Тогда
	Возврат;
КонецЕсли;
ОписаниеОповещения = Новый ОписаниеОповещения("ПослеПомещенияФайла", ЭтаФорма);
НачатьПомещениеФайла(ОписаниеОповещения,, ВыбранныйФайл[0], Ложь, УникальныйИдентификатор);
КонецПроцедуры

&НаКлиенте
Процедура ПослеПомещенияФайла(Результат, Адрес, ВыбранноеИмяФайла,ДопПараметры) Экспорт
Если Не
Результат Тогда
Возврат;
КонецЕсли;
СсылкаНаФотографию = Адрес;
Модифицированность = Истина;
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	Если ЭтоАдресВременногоХранилища(СсылкаНаФотографию) Тогда
		ФайлКартинки = ПолучитьИзВременногоХранилища(СсылкаНаФотографию);
		ТекущийОбъект.Фотография = Новый ХранилищеЗначения(ФайлКартинки);
		УдалитьИзВременногоХранилища(СсылкаНаФотографию);
		СсылкаНаФотографию = ПолучитьНавигационнуюСсылку(Объект.Ссылка,"Фотография");
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	СсылкаНаФотографию = ПолучитьНавигационнуюСсылку(Объект.Ссылка,"Фотография");
КонецПроцедуры                                                                                

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
    Если Модифицированность И ЭтоАдресВременногоХранилища(СсылкаНаФотографию) Тогда
        УдалитьИзВременногоХранилища(СсылкаНаФотографию);
    КонецЕсли;
КонецПроцедуры


