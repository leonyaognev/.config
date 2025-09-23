# This file is part of ranger, the console file manager.
# License: GNU GPL version 3, see the file "AUTHORS" for details.

from __future__ import absolute_import, division, print_function

from ranger.gui.color import (
    black, bold, default, default_colors, dim, normal, reverse, white)
from ranger.gui.colorscheme import ColorScheme


class BW(ColorScheme):
    progress_bar_color = white  # Прогресс-бар будет белым

    def use(self, context):
        fg, bg, attr = default_colors

        if context.reset:
            return default_colors

        elif context.in_browser:
            if context.selected:
                attr = reverse
            else:
                attr = normal
            if context.empty or context.error:
                bg = black
                fg = white
            if context.border:
                fg = white
            if context.document:
                attr |= normal
                fg = white
            if context.media:
                fg = white
            if context.container:
                fg = white
            if context.directory:
                attr |= bold
                fg = white
            elif context.executable and not \
                    any((context.media, context.container,
                         context.fifo, context.socket)):
                attr |= bold
                fg = white
            if context.socket:
                attr |= bold
                fg = white
            if context.fifo or context.device:
                fg = white
                if context.device:
                    attr |= bold
            if context.link:
                fg = white if context.good else white
                attr |= bold
            if context.tag_marker and not context.selected:
                attr |= bold
                fg = white
            if not context.selected and (context.cut or context.copied):
                attr |= bold
                fg = black
                bg = white
            if context.main_column:
                if context.selected:
                    attr |= bold
                if context.marked:
                    attr |= bold
                    fg = white
            if context.badinfo:
                fg = white
                attr |= bold

            if context.inactive_pane:
                fg = white
                attr |= dim

        elif context.in_titlebar:
            attr |= bold
            fg = white
            if context.hostname:
                fg = white
            elif context.directory:
                fg = white
            elif context.tab:
                bg = white
                fg = black
            elif context.link:
                fg = white

        elif context.in_statusbar:
            if context.permissions:
                fg = white
            if context.marked:
                attr |= bold | reverse
                fg = white
            if context.frozen:
                attr |= bold | reverse
                fg = white
            if context.message:
                if context.bad:
                    attr |= bold
                    fg = white
                    bg = black
            if context.loaded:
                bg = self.progress_bar_color
            if context.vcsinfo:
                fg = white
                attr &= ~bold
            if context.vcscommit:
                fg = white
                attr &= ~bold
            if context.vcsdate:
                fg = white
                attr &= ~bold

        if context.text:
            if context.highlight:
                attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = white
            if context.selected:
                attr |= reverse
            if context.loaded:
                if context.selected:
                    fg = self.progress_bar_color
                else:
                    bg = self.progress_bar_color

        if context.vcsfile and not context.selected:
            attr &= ~bold
            fg = white  # Все VCS-статусы в белом

        elif context.vcsremote and not context.selected:
            attr &= ~bold
            fg = white  # Все VCS-статусы в белом

        return fg, bg, attr
