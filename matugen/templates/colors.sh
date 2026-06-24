wallpaper="/home/ognev/Images/wallpaper/wall_8.jpg"

# Special
background='{{ colors.background.default.hex }}'
foreground='{{ colors.on_background.default.hex }}'
cursor='{{ colors.on_background.default.hex }}'

# Colors
color0='{{ colors.surface_container_lowest.default.hex }}'
color1='{{ colors.error.default.hex }}'
color2='{{ colors.primary.default.hex }}'
color3='{{ colors.secondary.default.hex }}'
color4='{{ colors.tertiary.default.hex }}'
color5='{{ colors.primary_container.default.hex }}'
color6='{{ colors.secondary_container.default.hex }}'
color7='{{ colors.on_surface.default.hex }}'

color8='{{ colors.surface_variant.default.hex }}'
color9='{{ colors.error_container.default.hex }}'
color10='{{ colors.primary.default.hex | lighten: 10.0 }}'
color11='{{ colors.secondary.default.hex | lighten: 10.0 }}'
color12='{{ colors.tertiary.default.hex | lighten: 10.0 }}'
color13='{{ colors.primary_container.default.hex | lighten: 10.0 }}'
color14='{{ colors.secondary_container.default.hex | lighten: 10.0 }}'
color15='{{ colors.on_background.default.hex }}'

# FZF colors
export FZF_DEFAULT_OPTS="
    $FZF_DEFAULT_OPTS
    --color fg:7,bg:0,hl:1,fg+:232,bg+:1,hl+:255
    --color info:7,prompt:2,spinner:1,pointer:232,marker:1
"

# Fix LS_COLORS being unreadable.
export LS_COLORS="${LS_COLORS}:su=30;41:ow=30;42:st=30;44:"
