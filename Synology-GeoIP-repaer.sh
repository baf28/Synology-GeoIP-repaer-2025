#!/bin/bash
# ОПАСНЫЙ СКРИПТ - НЕ РЕКОМЕНДУЕТСЯ К ИСПОЛЬЗОВАНИЮ

echo "ВНИМАНИЕ: Этот скрипт перезаписывает системную базу GeoIP!"
echo "Нажмите Ctrl+C для отмены или Enter для продолжения..."
read

# Создаем временную папку
TEMP_DIR="/tmp/geoip_update_$(date +%s)"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Скачиваем архив (замените URL на ваш реальный)
echo "Скачиваю архив с базой GeoIP..."
wget -q "https://github.com/baf28/Synology-GeoIP-repaer-2025/raw/refs/heads/main/geoip-backup-20251203.tar.gz" -O geoip.tar.gz

# Проверяем успешность скачивания
if [ ! -f "geoip.tar.gz" ]; then
    echo "Ошибка: не удалось скачать архив"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Распаковываем
echo "Распаковываю архив..."
tar -xzf geoip.tar.gz

# Останавливаем файрвол для безопасности
#echo "Останавливаю файрвол..."
#/usr/syno/bin/synoservice --stop firewall

# Копируем файлы (с созданием резервной копии)
echo "Создаю резервную копию текущей базы..."
BACKUP_DIR="/var/db/geoip-database-backup-$(date +%Y%m%d)"
cp -r /var/db/geoip-database "$BACKUP_DIR"

echo "Копирую новые файлы..."
cp -r "$TEMP_DIR"/geoip-database/* /var/db/geoip-database/
cp "$TEMP_DIR"/GeoLite2-City.mmdb /var/db/geoip-database/ 2>/dev/null || true

# Настраиваем права
echo "Настраиваю права доступа..."
chown -R root:root /var/db/geoip-database/
chmod -R 755 /var/db/geoip-database/

# Обновляем файрвол
echo "Обновляю файрвол..."
/usr/syno/bin/synofirewallUpdater --update

# Запускаем файрвол
#echo "Запускаю файрвол..."
#/usr/syno/bin/synoservice --start firewall

# Очистка
echo "Очищаю временные файлы..."
rm -rf "$TEMP_DIR"

echo "Готово! Старая база сохранена в: $BACKUP_DIR"
echo "Перезагрузите DSM или перезапустите файрвол для применения изменений."