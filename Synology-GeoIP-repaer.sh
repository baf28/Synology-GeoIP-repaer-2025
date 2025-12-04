#!/bin/bash
# Скрипт создал Alexandr Linux site bafista.ru при помощи DeepSeek
# curl -fsSL https://github.com/baf28/Synology-GeoIP-repaer-2025/raw/refs/heads/main/Synology-GeoIP-repaer.sh | bash

# Проверка прав root
if [ "$(id -u)" -ne 0 ]; then
    echo "ОШИБКА: Скрипт должен запускаться из-под root!"
    echo "Подключитесь к Synology по SSH как root и выполните команду снова."
    exit 1
fi

echo "=== Замена базы GeoIP для Synology ==="

# Создаем временную папку
TEMP_DIR="/tmp/geoip_update_$(date +%s)"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Скачиваем архив
echo "Скачиваю архив..."
wget -q "https://github.com/baf28/Synology-GeoIP-repaer-2025/raw/refs/heads/main/geoip-backup-20251203.tar.gz" -O geoip.tar.gz

# Проверяем успешность скачивания
if [ ! -f "geoip.tar.gz" ]; then
    echo "Ошибка: не удалось скачать архив"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Распаковываем
echo "Распаковываю..."
tar -xzf geoip.tar.gz

# Резервная копия
echo "Создаю резервную копию..."
BACKUP_DIR="/var/db/geoip-database-backup-$(date +%Y%m%d)"
cp -r /var/db/geoip-database "$BACKUP_DIR"

# Копируем новые файлы
echo "Копирую файлы..."
cp -r "$TEMP_DIR"/geoip-database/* /var/db/geoip-database/

# Права доступа
echo "Настраиваю права..."
chown -R root:root /var/db/geoip-database/
chmod -R 755 /var/db/geoip-database/

# Обновляем файрвол
echo "Обновляю файрвол..."
/usr/syno/bin/synofirewallUpdater --update

# Очистка
rm -rf "$TEMP_DIR"

echo "Готово! Резервная копия: $BACKUP_DIR"
echo "Перезагрузите DSM для применения изменений."