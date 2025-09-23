#!/bin/sh

get_icon() {
    code="$1"
    is_day="$2"

    case $code in
        1000) [ "$is_day" -eq 1 ] && icon="" || icon="" ;;  # ясно, день/ночь
        1003) icon="🌤" ;;  # немного облаков
        1006) icon="☁️" ;;  # облачно
        1009) icon="☁️" ;;  # пасмурно
        1030|1135|1147) icon="🌫" ;;  # туман
        1063|1150|1153|1168|1171|1180|1183|1186|1189|1192|1195|1240|1243|1246) 
            [ "$is_day" -eq 1 ] && icon="🌦" || icon="🌧" ;;  # дождь
        1087|1273|1276|1279|1282) icon="⛈" ;;  # гроза
        1114|1117|1210|1213|1216|1219|1222|1225|1237|1255|1258|1261|1264) icon="❄️" ;;  # снег
        *) icon="❓" ;;  # неизвестно
    esac

    echo "$icon"
}

KEY="ed52dc34622f4b75823221426252107"
CITY="Novosibirsk"
SYMBOL="°"
API="http://api.weatherapi.com/v1/current.json"

weather=$(curl -sf "$API?key=$KEY&q=$CITY&lang=ru")

if [ -n "$weather" ]; then
    temp=$(echo "$weather" | jq '.current.temp_c' | cut -d "." -f1)
    code=$(echo "$weather" | jq '.current.condition.code')
    is_day=$(echo "$weather" | jq '.current.is_day')

    icon=$(get_icon "$code" "$is_day")

    echo "$icon ${temp}${SYMBOL}"
else
    echo "⚠️ Нет данных"
fi
