class Widget:

    def __init__(self):
        self.text = ''
        self.color = ''
        self.background = ''
        self.border = {'color': '',
                       'top': 0, 'right': 0, 'bottom': 0, 'left': 0}

        self._icon_meta = {
            'foreground': 'black',
            'background': 'white',
            'value': None
        }

    def icon_color(self, foreground='black', background='white'):
        self._icon_meta['foreground'] = foreground
        self._icon_meta['background'] = background

    @property
    def icon(self):
        fmt = '<span foreground="{foreground}" background="{background}">{value}</span>'

        return fmt.format(**self._icon_meta)

    @icon.setter
    def icon(self, value):
        self._icon_meta['value'] = value

    @icon.deleter
    def icon(self):
        self._icon_meta['value'] = None

    @property
    def full_text(self):
        if self._icon_meta['value'] and self.text:
            return self.icon + ' ' + self.text
        else:
            return self.text

    def to_dict(self):
        out = {
            'full_text': self.full_text,
            'markup': 'pango',
            'separator': False,
            'separator_block_width': 6
        }

        if self.color:
            out['color'] = self.color

        if self.background:
            out['background'] = self.background

        if self.border['color']:
            out['border'] = self.border['color']

            if self.border['top'] != 1:
                out['border_top'] = self.border['top']

            if self.border['right'] != 1:
                out['border_right'] = self.border['right']

            if self.border['bottom'] != 1:
                out['border_bottom'] = self.border['bottom']

            if self.border['left'] != 1:
                out['border_left'] = self.border['left']

        return out

    def __repr__(self):
        return str(self.to_dict())
