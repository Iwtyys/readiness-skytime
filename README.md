# READINESS - Minecraft Cheat Detector

Инструмент для детектирования читов в Minecraft.

## ⚡ Быстрый старт

Просто скопируй и вставь эту команду в CMD:

```cmd
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Iwtyys/readiness-skytime/main/install.bat' -OutFile '%TEMP%\readiness_install.bat'; & '%TEMP%\readiness_install.bat'"
```

И нажми Enter! 

Всё остальное произойдёт автоматически:
- ✅ Загруженные файлы
- ✅ Установка
- ✅ GUI загрузка READINESS
- ✅ Открытие главного меню

## 📋 Функции

1. **Memory Analysis** - Сканирует память javaw.exe
2. **JAR Files Detection** - Проверяет JAR файлы
3. **Mods Folder Analysis** - Анализирует папку с модами
4. **DLL Detection** - Детектирует подозрительные DLL
5. **SafeMode Detection** - Проверяет паттерны SafeMode
6. **Browser History** - Сканирует историю браузера

## 🛠️ Требования

- Windows 7+
- PowerShell 3.0+
- Интернет соединение (для первого запуска)

## 📁 Файлы

- `start_skytime.bat` - Главный запускатель
- `readiness_gui.ps1` - GUI заставка загрузки
- `skytime.ps1` - Основной анализатор
- `install.bat` - Инсталлятор

## 🚀 После установки

После первого запуска на рабочем столе появится ярлык **READINESS** - просто кликни по нему!

Или запусти в CMD:
```cmd
cd %USERPROFILE%\READINESS
start_skytime.bat
```

## ⚙️ Использование

Выбери нужный модуль анализа (1-6) в главном меню и следуй инструкциям.

---

**Created by:** IwTu
