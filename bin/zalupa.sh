#!/usr/bin/env bash
# ip_telephony_report.sh
# Быстрый эвристический сбор данных по решениям IP-телефонии.
# Использование:
#   ./ip_telephony_report.sh Asterisk FreePBX Kamailio
# Если аргументы не заданы, берёт Asterisk FreePBX Kamailio.

set -euo pipefail
IFS=$'\n\t'

# --- Настройки ---
OUTDIR="./iptelephony_report_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"
TEMP="$OUTDIR/tmp"
mkdir -p "$TEMP"

# Требуемые утилиты
for cmd in curl jq grep sed awk; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo "Ошибка: требуется утилита: $cmd" >&2
    exit 1
  fi
done

USE_PUP=0
if command -v pup >/dev/null 2>&1; then
  USE_PUP=1
fi

# Ключевые шаблоны для поиска
fields=(
  "license|licen[cs]e|licensed under|proprietary|commercial|GPL|MIT|AGPL|BSD"
  "requirements|system requirements|operating system|OS:|CPU|memory|RAM|disk"
  "web interface|web-based|GUI|graphical user interface|CLI|command line|console"
  "SIP|IAX|WebRTC|RTP|SIPS|SRTP|SIP-TLS|SIP over TLS"
  "simultaneous calls|concurrent calls|scalab|scalability|users|number of users|calls per second"
  "TLS|SRTP|encryption|security|fail2ban|IDS|authentication|authorization|attack|DDoS"
  "easy to use|user-friendly|admin interface|install|quick install|setup|configuration|web GUI"
  "feature|features|notable|special|unique|capability"
)

# Вывод заголовков
echo "# Отчёт по решениям IP-телефонии" > "$OUTDIR/report.md"
echo "" >> "$OUTDIR/report.md"
echo "_Сформировано автоматически (эвристический парсер). Проверьте и поправьте вручную._" >> "$OUTDIR/report.md"
echo "" >> "$OUTDIR/report.md"

# Решения: аргументы или умолчание
if [ $# -ge 1 ]; then
  SOLS=("$@")
else
  SOLS=("Asterisk" "FreePBX" "Kamailio")
fi

declare -A RESULT_SNIPPETS

# Функция: найти страницу в Википедии через opensearch
wiki_search() {
  local name="$1"
  local api="https://en.wikipedia.org/w/api.php?action=opensearch&search=$(printf '%s' "$name" | sed 's/ /%20/g')&limit=1&format=json"
  local resp
  resp=$(curl -sSfL "$api" || echo "")
  if [ -z "$resp" ]; then
    echo ""
    return
  fi
  local url
  url=$(echo "$resp" | jq -r '.[3][0] // empty')
  echo "$url"
}

# Скачиваем и сохраняем основные страницы: вики (если есть) + поиск DDG (серебряная пуля нет, но попробуем wiki+official)
download_pages() {
  local name="$1"
  local outpref="$2"
  local wiki_url
  wiki_url=$(wiki_search "$name")
  if [ -n "$wiki_url" ]; then
    echo "Found wiki for $name: $wiki_url"
    curl -sSfL "$wiki_url" -o "${outpref}_wiki.html" || true
  else
    echo "No wiki found for $name"
  fi

  # Попытка найти официальный сайт через DuckDuckGo opensearch-like: используем duckduckgo html-страницу
  # (эвристика: ищем 'official' + name)
  local ddg="https://duckduckgo.com/html/?q=$(printf '%s' "$name official site" | sed 's/ /%20/g')"
  curl -sSfL "$ddg" -o "${outpref}_ddg.html" || true

  # Извлечь первые внешние ссылки из страницы duckduckgo:
  # Если pup доступен — используем его
  if [ "$USE_PUP" -eq 1 ]; then
    pup 'a.result__a attr{href}' < "${outpref}_ddg.html" | sed -n '1,5p' > "${outpref}_links.txt" || true
  else
    # fallback: grep href, простая эвристика
    grep -Eo 'https?://[^"]+' "${outpref}_ddg.html" | grep -E 'http' | sed 's/&amp;/\&/g' | sed 's/%3A/:/g' | sed 's/%2F/\//g' | sed -n '1,10p' > "${outpref}_links.txt" || true
  fi

  # Скачиваем первые несколько ссылок
  head -n 5 "${outpref}_links.txt" | nl -ba | while read -r n url; do
    url=$(echo "$url" | sed 's/&amp;/\&/g')
    [ -z "$url" ] && continue
    # filter out duckduckgo internal links
    if echo "$url" | grep -q "duckduckgo.com"; then continue; fi
    safe_fn="$(printf '%s' "$url" | sed 's/[^A-Za-z0-9]/_/g')"
    echo "  downloading: $url"
    curl -sSfL "$url" -o "${outpref}_link_${n}.html" || true
  done
}

# Функция: извлечение фрагментов по ключевым словам из набора файлов
extract_snippets() {
  local name="$1"
  local outpref="$2"
  local snippets_file="$outpref_snippets.txt"
  : > "$snippets_file"
  for pat in "${fields[@]}"; do
    # для каждого html-файла в префиксе
    for f in ${outpref}_*.html; do
      [ -f "$f" ] || continue
      # очистим тэги (примитивно)
      # используем awk чтобы взять контекст вокруг совпадения
      grep -i -n -E "$(echo "$pat" | sed 's/|/\\|/g')" "$f" 2>/dev/null | head -n 6 | while read -r line; do
        lineno=$(echo "$line" | cut -d: -f1)
        txt=$(echo "$line" | sed 's/^[0-9]\+://')
        echo "[$(basename "$f"):$lineno] $txt" >> "$snippets_file"
      done
    done
    # если pup доступен, дополнительно вытаскиваем текст узлов с паттерном
    if [ "$USE_PUP" -eq 1 ]; then
      for f in ${outpref}_*.html; do
        pup "body text{}" < "$f" | grep -i -E "$pat" -n | head -n 6 >> "$snippets_file" || true
      done
    fi
  done
  # Уберём дубли
  sort -u "$snippets_file" -o "$snippets_file"
  RESULT_SNIPPETS["$name"]="$snippets_file"
}

# Главный цикл по решениям
for sol in "${SOLS[@]}"; do
  name="$(echo "$sol" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  safe="$(echo "$name" | sed 's/[^A-Za-z0-9]/_/g')"
  outpref="$TEMP/$safe"
  echo "=== Обрабатываю: $name ==="
  download_pages "$name" "$outpref"
  extract_snippets "$name" "$outpref"
done

# Сборка Markdown-таблицы
echo "## Сравнительная таблица" >> "$OUTDIR/report.md"
echo "" >> "$OUTDIR/report.md"

# Заголовок таблицы
header="| Параметр | $(printf '%s | ' "${SOLS[@]}")"
# fix trailing
header=$(echo "$header" | sed 's/ | $//')
sep="|---|"
for _ in "${SOLS[@]}"; do sep="$sep---|"; done
echo "$header" >> "$OUTDIR/report.md"
echo "$sep" >> "$OUTDIR/report.md"

# Основные параметры: мы возьмём за основу набор полей и вставим первые найденные строки
params=("Лицензия" "Требования к серверу/системе" "Интерфейс администрирования" "Поддержка протоколов" "Масштабируемость" "Безопасность" "Удобство использования и настройки" "Особенности / Примечания")

for p in "${params[@]}"; do
  line="| $p "
  for sol in "${SOLS[@]}"; do
    snippets_file="${RESULT_SNIPPETS[$sol]}"
    snippet=""
    if [ -f "$snippets_file" ]; then
      # эвристика: подберём ключевые слова для поля
      case "$p" in
        "Лицензия")
          snippet=$(grep -iE 'GPL|MIT|AGPL|BSD|proprietary|commercial|license|licensed' "$snippets_file" 2>/dev/null | head -n1 || true)
          ;;
        "Требования к серверу/системе")
          snippet=$(grep -iE 'system requirements|operating system|OS:|CPU|memory|RAM|disk' "$snippets_file" 2>/dev/null | head -n1 || true)
          ;;
        "Интерфейс администрирования")
          snippet=$(grep -iE 'web interface|web-based|GUI|graphical|CLI|command line|console' "$snippets_file" 2>/dev/null | head -n1 || true)
          ;;
        "Поддержка протоколов")
          snippet=$(grep -iE 'SIP|IAX|WebRTC|RTP|SRTP|SIPS|TLS' "$snippets_file" 2>/dev/null | tr '\n' ' ' | sed 's/  */; /g' | sed 's/; $//' | sed 's/^\s*//' | sed 's/\s*$//' | cut -c1-200)
          ;;
        "Масштабируемость")
          snippet=$(grep -iE 'concurrent calls|simultaneous calls|scalab|users|number of users|calls per second' "$snippets_file" 2>/dev/null | head -n1 || true)
          ;;
        "Безопасность")
          snippet=$(grep -iE 'TLS|SRTP|encryption|security|fail2ban|DDoS|authentication|authorization' "$snippets_file" 2>/dev/null | head -n1 || true)
          ;;
        "Удобство использования и настройки")
          snippet=$(grep -iE 'easy to use|user-friendly|admin interface|quick install|setup|configuration|web GUI' "$snippets_file" 2>/dev/null | head -n1 || true)
          ;;
        *)
          snippet=$(head -n1 "$snippets_file" 2>/dev/null || true)
          ;;
      esac
    fi
    if [ -z "$snippet" ]; then snippet="(не найдено автоматически — проверить)"; fi
    # escape pipes
    snippet=$(echo "$snippet" | sed 's/|/\\|/g' | sed 's/[\r\n]/ /g' | sed 's/^[ \t]*//;s/[ \t]*$//')
    line="$line| $snippet "
  done
  line="$line|"
  echo "$line" >> "$OUTDIR/report.md"
done

# Добавим раздел с "анализом" (черновик плюсов/минусов) по каждому решению
echo "" >> "$OUTDIR/report.md"
echo "## Черновик анализа (плюсы / минусы — автоматическое предложение)" >> "$OUTDIR/report.md"
for sol in "${SOLS[@]}"; do
  echo "" >> "$OUTDIR/report.md"
  echo "### $sol" >> "$OUTDIR/report.md"
  echo "" >> "$OUTDIR/report.md"
  snippets_file="${RESULT_SNIPPETS[$sol]}"
  # Сформируем плюсы/минусы из найденных фраз (эвристика)
  echo "**Преимущества:**" >> "$OUTDIR/report.md"
  if [ -f "$snippets_file" ]; then
    grep -iE 'easy|user-friendly|web GUI|web interface|scalab|SIP|Open Source|GPL|MIT|features|flexible|modular' "$snippets_file" | head -n5 | sed 's/^/- /' >> "$OUTDIR/report.md" || echo "- (не найдено автоматически)" >> "$OUTDIR/report.md"
  else
    echo "- (не найдено автоматически)" >> "$OUTDIR/report.md"
  fi
  echo "" >> "$OUTDIR/report.md"
  echo "**Недостатки:**" >> "$OUTDIR/report.md"
  if [ -f "$snippets_file" ]; then
    grep -iE 'complex|difficult|proprietary|commercial|closed source|steep|limitations|resource' "$snippets_file" | head -n5 | sed 's/^/- /' >> "$OUTDIR/report.md" || echo "- (не найдено автоматически)" >> "$OUTDIR/report.md"
  else
    echo "- (не найдено автоматически)" >> "$OUTDIR/report.md"
  fi
done

# Скопируем все собранные html в OUTDIR для ручной проверки
cp -r "$TEMP"/* "$OUTDIR/" 2>/dev/null || true

echo ""
echo "Готово. Отчёт и собранные данные лежат в папке: $OUTDIR"
echo "Открой файл: $OUTDIR/report.md  — это Markdown с таблицей и черновиком анализа."
echo ""
echo "ВАЖНО (читай):"
echo " - Это автоматизированный черновик. Парсер использует простые эвристики и может ошибаться."
echo " - Проверь лицензии, цифры по масштабируемости и безопасность вручную по официальным источникам."
echo " - Если хочешь, могу улучшить парсер (включить GitHub API, парсить JSON, использовать headless-браузер), но для этого потребуются доп. права/токены и больше кода."
