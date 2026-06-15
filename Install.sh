#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}    🚀 Оффлайн-установщик Flatpak-бандлов${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"

cd "$(dirname "$0")" || exit 1

# Находим ВСЕ .flatpak файлы
shopt -s nullglob
BUNDLES=(*.flatpak)
shopt -u nullglob

echo -e "${YELLOW}📁 Поиск в: $(pwd)${NC}"

if [ ${#BUNDLES[@]} -eq 0 ]; then
    echo -e "${RED}❌ Бандлы не найдены!${NC}"
    echo -e "${YELLOW}💡 Убедитесь, что файлы .flatpak в папке:${NC}"
    ls -la *.flatpak 2>/dev/null || echo "   Нет .flatpak файлов"
    exit 1
fi

echo -e "${GREEN}✅ Найдено ${#BUNDLES[@]} бандлов:${NC}"
for f in "${BUNDLES[@]}"; do
    echo -e "  📦 $f"
done

install_flatpak() {
    local FILE=$1
    echo -e "\n  ${YELLOW}→ Установка:${NC} $FILE"
    
    if flatpak install --user --bundle -y "$FILE" 2>&1; then
        echo -e "  ${GREEN}✅ Успешно (user)${NC}"
        return 0
    fi
    
    echo -e "  ${YELLOW}⚠️ Пробуем с sudo...${NC}"
    if sudo flatpak install --system --bundle -y "$FILE" 2>&1; then
        echo -e "  ${GREEN}✅ Успешно (system)${NC}"
        return 0
    fi
    
    echo -e "  ${RED}❌ Ошибка установки${NC}"
    return 1
}

# Сначала все runtime
echo -e "\n${BLUE}⚙️ Шаг 1: Установка runtime...${NC}"
for f in "${BUNDLES[@]}"; do
    if [[ "$f" == *"runtime"* ]]; then
        install_flatpak "$f"
    fi
done

# Потом все приложения
echo -e "\n${BLUE}🎯 Шаг 2: Установка приложений...${NC}"
for f in "${BUNDLES[@]}"; do
    if [[ "$f" == *"app"* ]]; then
        install_flatpak "$f"
    fi
done

echo -e "\n${GREEN}✨ Установка завершена!${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
