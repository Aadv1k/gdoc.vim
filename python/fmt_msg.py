class GdocErr(Exception):
    def __init__(self, err):
        self.err = err

    def __str__(self):
        return '[gdoc.vim] %s' % (self.err)


