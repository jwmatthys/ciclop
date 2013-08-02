import pyo

class SpectralDelay(pyo.PyoObject):
    def __init__(self, input, count=20, 
                 maxdelay=2., q=5., feedback=0.,
                 minfreq=50, maxfreq=5000, mul=1, add=0):
        pyo.PyoObject.__init__(self, mul, add)
        self._input, self._count        = input, count
        self._maxdelay  = maxdelay
        self._q, self._feedback         = q, feedback
        self._minfreq, self._maxfreq      = minfreq, maxfreq
        self._mul, self._add            = mul, add
        self._in_fader                  = pyo.InputFader(input)
        
        self._bands = pyo.BandSplit(input, num=count, mul=1., 
                                    min=minfreq, max=maxfreq, q=q)
        
        self._out = pyo.Delay(self._bands, 
                          delay=[pyo.random.uniform(0.,1) * maxdelay
                                 for _ in xrange(count)], 
                          maxdelay=20, feedback=feedback, mul=mul*1./count, 
                          add=add)

        self._base_objs = self._out.getBaseObjects()
        
        
    def setInput(self, x, fadetime=0.05):
        """
        Replace the `input` attribute.
        
        Parameters:

        x : PyoObject
            New signal to process.
        fadetime : float, optional
            Crossfade time between old and new input. Defaults to 0.05.

        """
        self._input = x
        self._in_fader.setInput(x, fadetime)
    
    def setMaxdelay(self, x):
        """
        Replace the `mindelay` attribute.
        
        Parameters:

        x : float or PyoObject
            New `mindelay` attribute.

        """
        self._maxdelay = x
        self._out.delay=[pyo.random.uniform(0.,1) * self._maxdelay
                         for _ in xrange(self._count)]
    
    def setQ(self, x):
        """
        Replace the `q` attribute.
        
        Parameters:

        x : float or PyoObject
            New `q` attribute.

        """
        self._q = x
        self._bands.q = self._q
    
    def setFeedback(self, x):
        """
        Replace the `feedback` attribute.
        
        Parameters:

        x : float or PyoObject
            New `feedback` attribute.

        """
        self._feedback = x
        self._out.feedback = self._feedback
    
    def ctrl(self, map_list=None, title=None, wxnoserver=False):
        self._map_list = [pyo.SLMap(0., 20., 'lin', 'maxdelay', self._maxdelay),
                          pyo.SLMap(.1, 100., 'log', 'q', self._q),
                          pyo.SLMap(0., 1., 'lin', 'feedback', self._feedback),
                          pyo.SLMapMul(self._mul)]
        pyo.PyoObject.ctrl(self, map_list, title, wxnoserver)
    
    @property
    def input(self):
        """PyoObject. Input signal to process.""" 
        return self._input
    @input.setter
    def input(self, x): self.setInput(x)
    
    @property
    def maxdelay(self):
        """PyoObject. Minimum channel delay.""" 
        return self._maxdelay
    @maxdelay.setter
    def maxdelay(self, x): self.setMaxdelay(x)
    
    @property
    def q(self):
        """PyoObject. Minimum channel delay.""" 
        return self._q
    @q.setter
    def q(self, x): self.setQ(x)
    
    @property
    def feedback(self):
        """PyoObject. Minimum channel delay.""" 
        return self._feedback
    @feedback.setter
    def feedback(self, x): self.setFeedback(x)


if __name__ == '__main__':
    from pyo import *
    from Tkinter import Tk
    from tkFileDialog import askopenfilename
    Tk().withdraw()
    s = Server(sr=48000,nchnls=2,audio='jack',jackname='pyo').boot().start()
    #path = askopenfilename()
    path = '/home/jwmatthys/Music/brahms1.wav'
    src = SfPlayer(path, loop=True)
    
    delay = SpectralDelay(input=src, count=50).out()
    delay.maxdelay=10
    delay.q=8
    delay.feedback=0
    delay.ctrl()
    
    b = delay.mix()
    
    s.gui(locals())
