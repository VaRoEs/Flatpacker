#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

trap 'tput cnorm; kill $(jobs -p) 2>/dev/null; echo -e "\n${RED}Сборка прервана!${NC}"; exit 1' INT TERM

BUNDLE_DIR="flatpak-bundles-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BUNDLE_DIR"

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}    📦 Flatpak Bundle Builder — Всеядный парсер (v5)${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"

clean_ref() {
    echo "$1" | tr -d '\r\n[:space:]'
}

start_spinner() {
    tput civis
    while :; do
        for X in '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏'; do
            echo -en "\r  ${CYAN}${X}${NC} Собираю бандл... "
            sleep 0.1
        done
    done &
    SPINNER_PID=$!
}

stop_spinner() {
    kill $SPINNER_PID > /dev/null 2>&1
    wait $SPINNER_PID 2>/dev/null
    echo -en "\r\033[K"
    tput cnorm
}

get_repo_path() {
    local REF=$(clean_ref "$1")
    local INSTALL_TYPE=$(flatpak info "$REF" | grep -i "Installation:" | awk '{print $2}' | tr -d '\r\n[:space:]')
    if [[ "$INSTALL_TYPE" == "user" ]]; then
        echo "$HOME/.local/share/flatpak/repo"
    else
        echo "/var/lib/flatpak/repo"
    fi
}

get_dependencies() {
    local APP_REF=$(clean_ref "$1")
    local DEPS=()
    local METADATA=$(flatpak info -m "$APP_REF" 2>/dev/null)
    
    local RUNTIME=$(echo "$METADATA" | grep "^runtime=" | cut -d'=' -f2 | tr -d '\r')
    if [[ -n "$RUNTIME" ]]; then
        RUNTIME=$(clean_ref "$RUNTIME")
        DEPS+=("runtime/$RUNTIME")
        echo -e "${YELLOW}  → Найден runtime: ${GREEN}$RUNTIME${NC}"
    fi
    
    local SDK=$(echo "$METADATA" | grep "^sdk=" | cut -d'=' -f2 | tr -d '\r')
    if [[ -n "$SDK" ]]; then
        SDK=$(clean_ref "$SDK")
        DEPS+=("runtime/$SDK")
        echo -e "${YELLOW}  → Найден SDK: ${GREEN}$SDK${NC}"
    fi
    
    local EXT_IDS=$(echo "$METADATA" | grep "^\[Extension " | awk '{print $2}' | tr -d ']\r\n')
    for EXT in $EXT_IDS; do
        EXT=$(clean_ref "$EXT")
        local INSTALLED_EXT=$(flatpak list --runtime --columns=ref | grep "runtime/$EXT/" | head -n 1 | tr -d '\r')
        if [[ -n "$INSTALLED_EXT" ]]; then
            INSTALLED_EXT=$(clean_ref "$INSTALLED_EXT")
            DEPS+=("$INSTALLED_EXT")
            echo -e "${YELLOW}  → Найдено расширение: ${GREEN}$INSTALLED_EXT${NC}"
        fi
    done
    
    if [ ${#DEPS[@]} -gt 0 ]; then
        printf '%s\n' "${DEPS[@]}" | sort -u
    fi
}

# --- 🔥 УМНЫЙ АДАПТИВНЫЙ ПАРСЕР 🔥 ---
create_bundle() {
    local FULL_REF=$(clean_ref "$1")
    local REPO_PATH=$(get_repo_path "$FULL_REF")
    
    # Считаем количество кусков (разделенных слэшем)
    local PARTS_COUNT=$(echo "$FULL_REF" | awk -F'/' '{print NF}')
    
    if [ "$PARTS_COUNT" -eq 4 ]; then
        # Современный формат: app/com.app.Name/x86_64/stable
        local REF_TYPE=$(echo "$FULL_REF" | cut -d'/' -f1)
        local REF_ID=$(echo "$FULL_REF" | cut -d'/' -f2)
        local REF_ARCH=$(echo "$FULL_REF" | cut -d'/' -f3)
        local REF_BRANCH=$(echo "$FULL_REF" | cut -d'/' -f4)
    elif [ "$PARTS_COUNT" -eq 3 ]; then
        # Старый формат ОС: com.app.Name/x86_64/stable
        # Раз префикса нет, значит это приложение (app)
        local REF_TYPE="app"
        local REF_ID=$(echo "$FULL_REF" | cut -d'/' -f1)
        local REF_ARCH=$(echo "$FULL_REF" | cut -d'/' -f2)
        local REF_BRANCH=$(echo "$FULL_REF" | cut -d'/' -f3)
    else
        echo -e "  ${RED}❌ Неизвестный формат ref: $FULL_REF${NC}"
        return 1
    fi
    
    local SAFE_NAME="${REF_TYPE}-${REF_ID}-${REF_ARCH}-${REF_BRANCH}"
    local OUTPUT="$BUNDLE_DIR/${SAFE_NAME}.flatpak"
    local ERR_LOG="/tmp/flatpak-err-${REF_ID}.log"
    
    echo -e "  ${BLUE}📦 Подготовка:${NC} $REF_ID ($REF_BRANCH)"
    
    start_spinner
    
    if [[ "$REF_TYPE" == "runtime" ]]; then
        flatpak build-bundle --runtime --arch="$REF_ARCH" "$REPO_PATH" "$OUTPUT" "$REF_ID" "$REF_BRANCH" > /dev/null 2> "$ERR_LOG"
        local STATUS=$?
    else
        flatpak build-bundle --arch="$REF_ARCH" "$REPO_PATH" "$OUTPUT" "$REF_ID" "$REF_BRANCH" > /dev/null 2> "$ERR_LOG"
        local STATUS=$?
    fi
    
    stop_spinner
    
    if [ $STATUS -eq 0 ]; then
        local SIZE=$(du -h "$OUTPUT" | cut -f1)
        echo -e "  ${GREEN}✅ Готов:${NC} $OUTPUT ${YELLOW}($SIZE)${NC}\n"
        rm -f "$ERR_LOG"
        return 0
    else
        echo -e "  ${RED}❌ Ошибка при создании бандла!${NC}"
        echo -e "  ${YELLOW}Лог ошибки:${NC} $(cat "$ERR_LOG" | tr '\n' ' ' | cut -c 1-150)\n"
        return 1
    fi
}
# -------------------------------------

echo -e "\n${BLUE}📱 Установленные приложения:${NC}\n"

APPS=()
while IFS= read -r line; do
    line=$(clean_ref "$line")
    if [[ -n "$line" ]]; then
        APPS+=("$line")
    fi
done < <(flatpak list --app --columns=ref)

for i in "${!APPS[@]}"; do
    printf "  ${GREEN}%3d${NC}) ${APPS[$i]}\n" $((i+1))
done

echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}📝 Введи номера (через пробел: 1 3 5), 'all' для всех, или 'q' для выхода:${NC} "
read -p "➜ " INPUT

if [[ "$INPUT" == "q" ]]; then
    exit 0
fi

SELECTED_APPS=()
if [[ "$INPUT" == "all" ]]; then
    SELECTED_APPS=("${APPS[@]}")
    echo -e "\n${GREEN}✅ Выбраны ВСЕ приложения (${#SELECTED_APPS[@]} шт.)${NC}"
else
    for NUM in $INPUT; do
        if [[ "$NUM" =~ ^[0-9]+$ ]] && [ "$NUM" -ge 1 ] && [ "$NUM" -le "${#APPS[@]}" ]; then
            SELECTED_APPS+=("${APPS[$((NUM-1))]}")
        else
            echo -e "${RED}⚠️ Неверный номер: $NUM (пропускаю)${NC}"
        fi
    done
fi

if [ ${#SELECTED_APPS[@]} -eq 0 ]; then
    exit 1
fi

echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}🔍 Анализирую зависимости...${NC}\n"

declare -A ALL_DEPS

for APP in "${SELECTED_APPS[@]}"; do
    echo -e "${BLUE}📌 Приложение:${NC} $APP"
    DEPS=$(get_dependencies "$APP")
    for DEP in $DEPS; do
        if [[ -n "$DEP" ]]; then
            ALL_DEPS["$DEP"]=1
        fi
    done
    echo ""
done

if [ ${#ALL_DEPS[@]} -gt 0 ]; then
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}📚 Создаю бандлы для зависимостей (${#ALL_DEPS[@]} шт.)...${NC}\n"
    
    for DEP in "${!ALL_DEPS[@]}"; do
        if flatpak info "$DEP" &>/dev/null; then
            create_bundle "$DEP"
        else
            echo -e "  ${RED}⚠️ Пропускаю опциональную зависимость (не установлена):${NC} $DEP\n"
        fi
    done
fi

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🎯 Создаю бандлы для приложений...${NC}\n"

for APP in "${SELECTED_APPS[@]}"; do
    create_bundle "$APP"
done

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✨ Готово! Все бандлы лежат здесь:${NC}"
echo -e "   📁 $(realpath "$BUNDLE_DIR")\n"

INSTALLER_FILE="$BUNDLE_DIR/install.sh"
cat > "$INSTALLER_FILE" << 'EOF'
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
